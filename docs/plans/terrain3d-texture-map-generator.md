# TextureMapGenerator — Feature Plan

## Overview

`TextureMapGenerator` is a `@tool` GDScript node that lives inside the `TerrainManager` scene. It reads height data from the terrain's storage layer and writes texture assignments into the Terrain3D **control map** so that each surface point is painted with the correct texture asset — blended smoothly across height-zone boundaries and automatically slope-shaded on steep faces.

---

## Scene Hierarchy

```
TerrainManager (Node3D)
├── Terrain3D
├── HeightmapGenerator   ← existing
└── TextureMapGenerator  ← new (this plan)
```

`TextureMapGenerator` is a plain `Node` (no 3D transform needed). It holds a reference to the sibling `Terrain3D` node.

---

## Supporting Resource: `HeightZone`

A lightweight exported `Resource` that describes one elevation band.

```gdscript
class_name HeightZone
extends Resource

@export var label: String = "Zone"
@export var texture_id: int = 0        # slot index in Terrain3DAssets (0–31)
@export var min_height: float = 0.0
@export var max_height: float = 50.0
```

Zones are ordered by `min_height` at generation time — the user does not need to keep them sorted manually.

---

## TextureMapGenerator Properties

```gdscript
@tool
class_name TextureMapGenerator
extends Node

## The Terrain3D node to paint. Assign in the inspector.
@export var terrain: Terrain3D

## One entry per elevation band. Can overlap — blend_width handles the transition.
@export var height_zones: Array[HeightZone] = []

## World-unit width of the cross-fade region between adjacent height zones.
## A value of 5 means ±2.5 units around each zone boundary is blended.
@export_range(0.0, 50.0, 0.5) var blend_width: float = 5.0

## Slope angle (degrees from vertical) above which autoshader takes over.
## 0 = all terrain auto-shaded; 90 = autoshader never used.
@export_range(0.0, 90.0, 1.0) var slope_threshold: float = 35.0

## Editor-only button — calls generate() when clicked.
@export_tool_button("Generate Texture Map", "Terrain3D")
var _generate_btn = generate
```

---

## Control Map Encoding (what gets written per pixel)

Each pixel in the Terrain3D control map is a packed `uint32` stored as `FORMAT_RF`. Relevant fields for this feature:

| Field | Bits | Set by this script |
|---|---|---|
| Base texture ID | 5 | Yes — primary zone texture |
| Overlay texture ID | 5 | Yes — adjacent zone texture for blending |
| Texture blend | 8 | Yes — 0 = 100 % base, 255 = 100 % overlay |
| Autoshader flag | 1 | Yes — set on steep slopes |
| UV angle/scale | 7 | Left at current value (not overwritten) |
| Hole / Nav flags | 2 | Overwritten (cleared to 0) |

`Terrain3DUtil` provides `enc_*` helpers (GDScript-accessible) and `as_float` / `as_uint` converters to build the packed value without manual bit arithmetic.

---

## Generation Algorithm

### Entry point

```
generate()
  1. Validate: terrain assigned, height_zones not empty, terrain.data != null
  2. Sort height_zones by min_height ascending
  3. Warn on heavy overlaps:
       for each pair (zones[i], zones[i+1]):
           if zones[i+1].min_height < zones[i].max_height - blend_width:
               push_warning("HeightZones '%s' and '%s' overlap by more than blend_width. \
                            Only the first matching zone pair will be used." \
                            % [zones[i].label, zones[i+1].label])
  4. For each region in terrain.data.get_regions_active():
       generate_region(region)          # pass the Terrain3DRegion object
  5. Call terrain.data.update_maps(Terrain3DRegion.TYPE_CONTROL, false)
     # false = only rebuild regions marked edited, not all
```

### Per-region pass

```
generate_region(region: Terrain3DRegion)
  1. control_img = region.get_map(Terrain3DRegion.TYPE_CONTROL)
     height_img  = region.get_map(Terrain3DRegion.TYPE_HEIGHT)
     # Both return Image references — edits are in-place, no set_map needed.
  2. Lock both images for pixel access (image.lock() in older Godot; in 4.x
     direct get/set_pixel is fine without lock)
  3. region_size = region.region_size
     For x in region_size, for y in region_size:
       height    = height_img.get_pixel(x, y).r         # FORMAT_RF → R = world height
       slope_deg = calc_slope(height_img, x, y, region.vertex_spacing)
       new_uint  = encode_control_pixel(height, slope_deg)
       new_color = Color(Terrain3DUtil.as_float(new_uint), 0.0, 0.0, 1.0)
       control_img.set_pixel(x, y, new_color)
  4. region.set_modified(true)
     region.set_edited(true)   # flags this region for selective update_maps
```

### Height → zone lookup + blend

```
encode_control_pixel(height, slope_deg) -> int:

  if slope_deg >= slope_threshold:
      base = nearest_zone(height).texture_id
      return Terrain3DUtil.enc_base(base) \
           | Terrain3DUtil.enc_overlay(base) \
           | Terrain3DUtil.enc_auto(true)

  zone_a, zone_b, blend_t = find_zones_and_blend(height)
  # blend_t ∈ [0.0, 1.0]
  #   0.0 → 100 % zone_a
  #   1.0 → 100 % zone_b

  blend_byte = int(blend_t * 255)   # enc_blend expects 0–255 int
  overlay_id = zone_b.texture_id if zone_b else zone_a.texture_id

  return Terrain3DUtil.enc_base(zone_a.texture_id) \
       | Terrain3DUtil.enc_overlay(overlay_id) \
       | Terrain3DUtil.enc_blend(blend_byte)
```

### `find_zones_and_blend` logic

```
find_zones_and_blend(height):
  for each pair (zones[i], zones[i+1]):
      boundary = zones[i].max_height   # = zones[i+1].min_height if they abut

      lower_edge = boundary - blend_width * 0.5
      upper_edge = boundary + blend_width * 0.5

      if height < lower_edge:
          continue to next pair
      if height <= upper_edge:
          t = (height - lower_edge) / blend_width   # 0→1
          return zones[i], zones[i+1], t

  # height is fully inside a single zone
  return nearest_zone(height), null, 0.0
```

### Slope calculation (central difference)

```
calc_slope(height_img, x, y, vertex_spacing) -> float (degrees):
  # vertex_spacing = region.vertex_spacing (world units per pixel, default 1.0)
  size = height_img.get_width()   # square image
  h_l = height_img.get_pixel(max(x-1, 0),    y).r
  h_r = height_img.get_pixel(min(x+1, size-1), y).r
  h_d = height_img.get_pixel(x, max(y-1, 0)).r
  h_u = height_img.get_pixel(x, min(y+1, size-1)).r
  dx = (h_r - h_l) / (2.0 * vertex_spacing)
  dy = (h_u - h_d) / (2.0 * vertex_spacing)
  normal = Vector3(-dx, 1.0, -dy).normalized()
  return rad_to_deg(acos(clamp(normal.dot(Vector3.UP), -1.0, 1.0)))
  # clamp guards against float precision issues feeding acos values outside [-1,1]
```

Border pixels clamp to the nearest valid sample (no out-of-bounds sampling across region edges needed for v1; cross-region accuracy is a future improvement).

> **Alternative:** `terrain.data.get_normal(global_position)` returns the interpolated normal at any world position, which could replace central difference. However calling it once per pixel in a tight loop is much slower than reading the Image directly — reserve it for the single-point `generate_at()` API path.

---

## Cliff-Only Autoshading Strategy

A powerful feature of this generator is the ability to delegate cliff texturing to the GPU while keeping manual or height-based control over flat terrain.

### 1. How it Works
The `TextureMapGenerator` identifies steep slopes (based on `slope_threshold`) and sets the **"Auto" bit** on those pixels in the control map.
- **Flat Ground**: The "Auto" bit is **OFF**. The shader uses the specific textures assigned by your `HeightZones`.
- **Cliffs**: The "Auto" bit is **ON**. The shader ignores the specific textures from the generator and instead uses the global slope-blending rules defined in the `Terrain3DMaterial`.

### 2. Required Material Configuration
For this to work, the `Terrain3DMaterial` on the `Terrain3D` node must be configured as follows:
- **Auto Shader**: `Enabled`
- **Auto Base Texture**: Set to your cliff/rock texture index (e.g., `4` for Rock). *Note: In Terrain3D, the "Base" texture is applied to steep slopes.*
- **Auto Overlay Texture**: Set to your primary ground texture index (e.g., `0` for Grass). *Note: In Terrain3D, the "Overlay" texture is applied to flat ground.*
- **Auto Slope**: Set the blend sharpness (e.g., `0.5`).

### 3. Benefits
- **Artistic Control**: You can still paint paths or height-based biomes (flowers vs. grass) on flat land.
- **Visual Fidelity**: The GPU handles the complex triplanar blending and steep-slope stretching for cliffs automatically.
- **Consistency**: All cliffs across the entire terrain will use a consistent rock texture and blend logic.

---

## Concrete API Reference (confirmed from docs)

These are the exact calls to use — the plan's pseudocode above maps to these.

```gdscript
# Iterate active regions
for region in terrain.data.get_regions_active():
    var ctrl_img: Image = region.get_map(Terrain3DRegion.TYPE_CONTROL)
    var h_img:    Image = region.get_map(Terrain3DRegion.TYPE_HEIGHT)
    var vs: float = region.vertex_spacing   # world units per pixel
    var sz: int   = region.region_size

    for x in sz:
        for y in sz:
            # Read height (FORMAT_RF → .r is the float height in world units)
            var h: float = h_img.get_pixel(x, y).r

            # ... compute new_uint via encode_control_pixel ...

            # Write back: pack uint into FORMAT_RF Color
            ctrl_img.set_pixel(x, y, Color(Terrain3DUtil.as_float(new_uint), 0.0, 0.0, 1.0))

    region.set_modified(true)
    region.set_edited(true)

# Rebuild GPU texture arrays for control map only, edited regions only
terrain.data.update_maps(Terrain3DRegion.TYPE_CONTROL, false)

# After the loop, clear edited flags
for region in terrain.data.get_regions_active():
    region.set_edited(false)
```

**Bit encoding with `Terrain3DUtil` (OR the results together):**

```gdscript
# Flat/blended pixel
var bits: int = Terrain3DUtil.enc_base(base_id) \
              | Terrain3DUtil.enc_overlay(overlay_id) \
              | Terrain3DUtil.enc_blend(blend_0_255)

# Steep slope pixel
var bits: int = Terrain3DUtil.enc_base(base_id) \
              | Terrain3DUtil.enc_overlay(base_id) \
              | Terrain3DUtil.enc_auto(true)
```

**Reading fields back from a uint pixel:**

```gdscript
Terrain3DUtil.get_base(pixel_uint)    # → int 0-31
Terrain3DUtil.get_overlay(pixel_uint) # → int 0-31
Terrain3DUtil.get_blend(pixel_uint)   # → int 0-255
Terrain3DUtil.is_auto(pixel_uint)     # → bool
Terrain3DUtil.is_hole(pixel_uint)     # → bool
Terrain3DUtil.is_nav(pixel_uint)      # → bool
```

**High-level single-point helpers** (slow in loops, fine for `generate_at()`):

```gdscript
terrain.data.set_control_base_id(global_pos, id)        # handles update internally
terrain.data.set_control_overlay_id(global_pos, id)
terrain.data.set_control_blend(global_pos, 0.0..1.0)    # note: float 0-1, not 0-255
terrain.data.set_control_auto(global_pos, true)
terrain.data.get_normal(global_pos)                     # → Vector3 terrain normal
terrain.data.is_in_slope(global_pos, Vector2(min,max))  # → bool slope check
# After any set_* calls:
terrain.data.update_maps(Terrain3DRegion.TYPE_CONTROL)
```

---

## Editor Button

Godot 4.3 supports `@export_tool_button` on `@tool` scripts, which renders a clickable button in the Inspector. Clicking it calls `generate()` directly without needing an `EditorPlugin` or a custom `EditorInspectorPlugin`.

```gdscript
@export_tool_button("Generate Texture Map", "Terrain3D")
var _generate_btn = generate
```

---

## Programmatic API (for use outside TerrainManager)

```gdscript
## Regenerate the full control map.
func generate() -> void

## Regenerate only the region that contains world_pos.
func generate_at(world_pos: Vector3) -> void

## Regenerate a specific region by its location index.
func generate_region(region_location: Vector2i) -> void
```

External callers (e.g. a world-streaming system or a HeightmapGenerator that just finished its pass) can do:

```gdscript
# In HeightmapGenerator or any other node:
var tmg = $"../TextureMapGenerator"
tmg.generate()

# Or after modifying a partial area:
tmg.generate_at(some_world_position)
```

A `signal generation_completed` can be emitted at the end of `generate()` for callers that need to react after the paint pass.

---

## Edge Cases & Considerations

| Concern | Handling |
|---|---|
| No zones defined | `generate()` prints a warning and returns early |
| `texture_id` out of range | Clamp to `terrain.assets.get_texture_count() - 1`; warn in editor |
| Height below all zones | Assign lowest zone's texture |
| Height above all zones | Assign highest zone's texture |
| Overlapping zone ranges | Warn at generate time with `push_warning` if two adjacent zones overlap by more than `blend_width`; first matching zone pair still wins |
| Terrain not yet loaded | Check `terrain.data != null` and region list not empty before iterating |
| Very large terrains | Region-by-region loop is already incremental; add an `await get_tree().process_frame` yield between regions in the editor pass to avoid hitching |

---

## Implementation Order

1. **`HeightZone` resource** — trivial, no dependencies
2. **Script skeleton** — `@tool`, exports, `generate()` stub, tool button
3. **Region iteration** — loop over regions, verify data access works
4. **Height → zone mapping** — no blending yet, solid zones only; verify visually
5. **Blend transition** — add `blend_width` logic; verify gradient between zones
6. **Slope / autoshader** — add slope calculation and `auto` flag; verify on hills
7. **Programmatic API** — expose `generate_at()`, emit `generation_completed`
8. **Guard rails** — all edge-case checks from the table above

---

## Terrain3D Functions Used

### `Terrain3DData` — accessed via `terrain.data`

| Call | Returns | Purpose |
|---|---|---|
| `terrain.data.get_regions_active()` | `Array[Terrain3DRegion]` | Iterate all active (non-deleted) regions |
| `terrain.data.update_maps(TYPE_CONTROL, false)` | `void` | Rebuild GPU texture arrays after editing; `false` = only regions marked `edited` |

---

### `Terrain3DRegion` — one object per active region

| Call | Returns | Purpose |
|---|---|---|
| `region.get_map(Terrain3DRegion.TYPE_CONTROL)` | `Image` | Direct reference to the control map image; edits are in-place |
| `region.get_map(Terrain3DRegion.TYPE_HEIGHT)` | `Image` | Direct reference to the height map image |
| `region.region_size` | `int` | Pixel dimensions of the region (e.g. 256) |
| `region.vertex_spacing` | `float` | World units per pixel (default 1.0); needed for slope calculation |
| `region.set_modified(true)` | `void` | Marks region to be written to disk on next save |
| `region.set_edited(true)` | `void` | Flags region for selective `update_maps` rebuild |
| `region.set_edited(false)` | `void` | Clears the flag after `update_maps` has been called |

**Map type constants** (used with `get_map` and `update_maps`):

| Constant | Value | Description |
|---|---|---|
| `Terrain3DRegion.TYPE_HEIGHT` | `0` | 32-bit float height values |
| `Terrain3DRegion.TYPE_CONTROL` | `1` | Packed uint32 texture/blend/flag data |
| `Terrain3DRegion.TYPE_COLOR` | `2` | RGBA color map |
| `Terrain3DRegion.TYPE_MAX` | `3` | All map types (used to rebuild everything) |

---

### `Terrain3DUtil` — static helpers, no instance needed

**Type conversion** (uint ↔ float memory reinterpretation — not numeric conversion):

| Call | Returns | Purpose |
|---|---|---|
| `Terrain3DUtil.as_uint(float)` | `int` | Reinterpret float memory as uint32; use on `image.get_pixel(x,y).r` |
| `Terrain3DUtil.as_float(int)` | `float` | Reinterpret uint32 memory as float; use before storing in `Color.r` |

**Encoding** (each returns a uint with only its bits set; OR them together):

| Call | Input | Purpose |
|---|---|---|
| `Terrain3DUtil.enc_base(id)` | `int` 0–31 | Set base texture ID bits |
| `Terrain3DUtil.enc_overlay(id)` | `int` 0–31 | Set overlay texture ID bits |
| `Terrain3DUtil.enc_blend(value)` | `int` 0–255 | Set blend value bits |
| `Terrain3DUtil.enc_auto(enable)` | `bool` | Set autoshader flag bit |
| `Terrain3DUtil.enc_hole(enable)` | `bool` | Set hole flag bit |
| `Terrain3DUtil.enc_nav(enable)` | `bool` | Set navigation flag bit |

**Decoding** (read individual fields from a uint pixel):

| Call | Returns | Purpose |
|---|---|---|
| `Terrain3DUtil.get_base(uint)` | `int` 0–31 | Read base texture ID |
| `Terrain3DUtil.get_overlay(uint)` | `int` 0–31 | Read overlay texture ID |
| `Terrain3DUtil.get_blend(uint)` | `int` 0–255 | Read blend value |
| `Terrain3DUtil.is_auto(uint)` | `bool` | Read autoshader flag |
| `Terrain3DUtil.is_hole(uint)` | `bool` | Read hole flag |
| `Terrain3DUtil.is_nav(uint)` | `bool` | Read navigation flag |

---

### High-level single-point API — used in `generate_at()` only

These operate on world-space positions and call `update_maps` internally. Too slow for the bulk pixel loop but convenient for point updates.

| Call | Notes |
|---|---|
| `terrain.data.set_control_base_id(pos, id)` | `id` clamped to 0–31 |
| `terrain.data.set_control_overlay_id(pos, id)` | `id` clamped to 0–31 |
| `terrain.data.set_control_blend(pos, value)` | `value` is float 0.0–1.0 (not 0–255) |
| `terrain.data.set_control_auto(pos, enable)` | |
| `terrain.data.get_height(pos)` | Returns `NAN` outside regions or on holes |
| `terrain.data.get_normal(pos)` | Returns terrain normal as `Vector3`; use instead of central difference for single points |
| `terrain.data.update_maps(TYPE_CONTROL)` | Must be called after any `set_*` calls |

---

## Open Questions (decide before coding)

- **Who owns zone boundaries?** Do adjacent zones share a boundary value (zone A max = zone B min), or is there a gap between them? The blend math above assumes they can abut or gap — blend_width bridges the transition regardless.
- **Cross-region slope accuracy?** Border pixels currently clamp to self — slope will be slightly wrong at region edges. Acceptable for v1.

