---
name: terrain3d
description: High-performance, GDExtension-based terrain system with GPU-driven mesh processing for Godot 4.
license: MIT
compatibility: Godot 4.x, Feudal Game project
metadata:
  repository: "https://github.com/TokisanGames/Terrain3D"
  maintainer: "TokisanGames"
  version: "Godot 4.x"
tags:
  - godot
  - plugin
  - feudal-age
  - terrain
  - shaders
---

# Terrain3D

A high-performance, GDExtension-based terrain system designed for large-scale environments in Godot 4. It uses GPU-driven geometric clipmap mesh processing and is written in C++.

## 1. Project Resource Standards

All Terrain3D-related files must be consolidated within the `assets/terrain3d/` directory to maintain project cleanliness:

| File Type | Recommended Path | Purpose |
| :--- | :--- | :--- |
| **Manager Scene** | `res://scenes/TerrainManager.tscn` | Central architectural hub for terrain ops |
| **Assets Resource** | `res://assets/terrain3d/terrain_assets.tres` | Stores texture and mesh library slots |
| **Material Resource** | `res://assets/terrain3d/terrain_material.tres` | Manages shader parameters and debug views |
| **Packed Textures** | `res://assets/terrain3d/textures/` | RGBA packed PNGs (e.g., `grass_alb_ht.png`) |
| **Binary Map Data** | `res://assets/terrain3d/data/` | High-precision height/control maps |

---

## 2. Terrain Texture Importer (Utility)

A helper script `res://scripts/util/TerrainTextureImporter.gd` is provided to streamline adding PBR textures from global asset folders into the Terrain3D hub.

### How to use:
1.  **Setup:** Add a node to your scene and attach `TerrainTextureImporter.gd`.
2.  **Assign:** Drag source textures (Albedo, Height, Normal, Roughness) from your global assets into the Inspector slots.
3.  **Configure:** Set the `Asset Name` and `UV Scale`.
4.  **Execute:** Click the **"Pack and Import Texture"** button.
5.  **Finalize:** After the script runs, select the new PNGs in `assets/terrain3d/textures/` and in the **Import Tab**:
    *   Set **Normal Map** to **Disabled**.
    *   Set **Mipmaps Generate** to **On**.
    *   Click **Reimport**.

The script automatically handles RGBA packing and adds the new texture to `res://assets/terrain3d/terrain_assets.tres`.

---

## 3. The Demo Folder (Immutable Reference)

The `demo/` folder (found in `src/feudal-age/demo/`) is a self-contained example provided by the Terrain3D plugin.
- **Do NOT move, rename, or modify** any files within the `demo/` folder.
- **Do NOT reference** demo assets (like `demo/data/assets.tres`) from main project scenes (like `World.tscn`).
- The demo should remain untouched as a functional baseline for plugin verification.

---

## 4. Architecture Overview

Terrain3D separates visual representation from data storage through several primary classes:

- **`Terrain3D`**: The main node managing rendering, collision, and tools.
- **`Terrain3DStorage`**: Container for all terrain data (Height, Control, Color).
- **`Terrain3DMaterial`**: Manages the shader, world background settings, and debug flags.
- **`Terrain3DAssets`**: A library resource (container) for **Textures** and **Meshes**.
- **`Terrain3DTextureAsset`**: Individual texture definition.
- **`Terrain3DMeshAsset`**: Foliage mesh definition for the instancer.

### TerrainManager Architecture
The project uses a `TerrainManager` node to encapsulate terrain logic:
- **`TerrainManager`**: Root Node3D; manages high-level lifecycle.
- **`Terrain3D`**: Primary plugin node.
- **`HeightMapGenerator`**: Procedural sculpting via noise.
- **`TextureMapGenerator`**: Elevation/slope-based auto-painting.

## 5. Map & Storage System

Terrain3D uses a region-based system (default 1024x1024). Data is stored in three primary maps:

| Map Type | Constant | Description |
| :--- | :--- | :--- |
| **Height** | `TYPE_HEIGHT` (0) | 32-bit float world height values. |
| **Control** | `TYPE_CONTROL` (1) | Packed `uint32` texture, blend, and flag data. |
| **Color** | `TYPE_COLOR` (2) | RGBA color map (multiplied onto albedo). |

## 6. The Control Map (Index Map)

Terrain3D uses an Index Map instead of traditional splatmaps to drastically reduce VRAM usage (up to 93% reduction).

### Control Map Format
Each pixel is a `uint32` packed into a `FORMAT_RF` image.

| Field | Bits | Range | Description |
| :--- | :--- | :--- | :--- |
| **Base ID** | 5 | 0–31 | Primary texture slot index. |
| **Overlay ID** | 5 | 0–31 | Secondary texture slot index for blending. |
| **Blend** | 8 | 0–255 | 0 = 100% Base, 255 = 100% Overlay. |
| **UV Angle** | 4 | 0–15 | Painted UV rotation. |
| **UV Scale** | 3 | 0–7 | Painted UV scale. |
| **Hole Flag** | 1 | 0/1 | If set, terrain is invisible/no-collision. |
| **Nav Flag** | 1 | 0/1 | Navigation layer hint. |
| **Auto Flag** | 1 | 0/1 | If set, Autoshader takes over this pixel. |

## 7. Texture & Asset Management

### Texture Packing Rules
Each texture slot (`Terrain3DTextureAsset`) requires exactly **two RGBA-packed files**:

| File | RGB Channels | Alpha Channel |
| :--- | :--- | :--- |
| **Albedo** | Base Color | **Height Map** (Displacement) |
| **Normal** | Normal Map (OpenGL +Y) | **Roughness Map** |

### Consistency Requirements
All textures within an array must match perfectly:
- All **Albedo** textures must be the same size and compression format.
- All **Normal** textures must be the same size and compression format.
- All must consistently have or not have mipmaps.

### Recommended Formats
- **DDS (BC3/DXT5):** Best for desktop (direct GPU use, better filter control).
- **PNG (VRAM Compressed):** Standard choice. Use **High Quality (BPTC)** if available.
- **Normal Map Format:** Use **OpenGL (+Y)**. DirectX normals (Unreal/Substance) must have the Green channel inverted.

## 8. Painting Workflow Summary

| Tool | Action | Description |
| :--- | :--- | :--- |
| **Paint Texture** | Hard Coverage | Sets Base + Overlay to same ID; Blend = 0. |
| **Spray Texture** | Soft Blend | Gradually blends in selected texture. Ctrl reduces. |
| **Autoshader** | Slope-Based | Marks regions as slope-driven auto-textured. |
| **Paint Color** | Multiply | Multiplies color onto terrain (shadows/variation). |
| **Paint Wetness** | Roughness | Modifies roughness (Negative = glossy). |
| **Paint Angle/Scale** | UV Transform | Per-vertex UV rotation/scale. |

## 9. Programmatic API Reference

### `Terrain3DUtil` (Static Helpers)

| Call | Returns | Purpose |
| :--- | :--- | :--- |
| `pack_image(rgb, a, inv_g, inv_a, norm_a, chan)` | `Image` | Pack two images into one RGBA. |
| `get_min_max(image)` | `Vector2` | Min and max R channel values; for height normalization. |
| `as_uint(float)` | `int` | Reinterpret `FORMAT_RF` pixel (float) as `uint32`. |
| `as_float(int)` | `float` | Reinterpret `uint32` as float for storage. |
| `enc_base(id)` | `int` | Bitwise encode base texture ID (0–31). |
| `enc_overlay(id)` | `int` | Bitwise encode overlay texture ID (0–31). |
| `enc_blend(val)` | `int` | Bitwise encode blend value (0–255). |
| `enc_auto(bool)` | `int` | Bitwise encode autoshader flag. |

**`pack_image` parameter detail:**
- `inv_g`: `true` to convert DirectX normals -> OpenGL.
- `inv_a`: `true` to convert Smoothness -> Roughness.
- `norm_a`: `true` recommended for height maps (stretches to full 0–1 range).
- `chan`: Which channel of `src_a` to use as alpha (R=0, G=1, B=2, A=3).

### `Terrain3DData` (Map Data & Regions)

Accessed via `terrain.data` or `terrain.get_data()`.

| Call | Returns | Purpose |
| :--- | :--- | :--- |
| `get_region_location(world_pos)` | `Vector2i` | Grid location of a region. |
| `get_region(location)` | `Terrain3DRegion` | Get the region object at a location. |
| `get_regions_active()` | `Array[Terrain3DRegion]` | List of all non-deleted regions. |
| `update_maps(type, full)` | `void` | Notify GPU that data has changed. |

**Crucial Region Validation Pattern:**
Always check for a null region instead of comparing against sentinel constants (like `INVALID_LOCATION` which does NOT exist).
```gdscript
var loc: Vector2i = terrain.data.get_region_location(world_pos)
var region: Terrain3DRegion = terrain.data.get_region(loc)
if not region:
    return # world_pos is outside any active region
```

### `Terrain3DAssets` (Resource)

| Property / Method | Description |
| :--- | :--- |
| `set_texture(id, tex)` | Assign a `Terrain3DTextureAsset` to slot 0–31. |
| `get_texture_count()` | Number of populated texture slots. |
| `clear_textures(regen)` | Remove source textures from VRAM. |
| `update_texture_list()` | Recompile arrays and send to shader. |

### `Terrain3DMaterial` (Resource)

| Property | Purpose |
| :--- | :--- |
| `auto_shader` | Automatically textures terrain based on slope. |
| `dual_scaling` | One texture at two scales based on distance. |
| `world_background` | Mesh outside regions: `NONE` / `FLAT` / `NOISE`. |
| `show_control_texture` | Debug view for texture IDs. |

## 10. Performance & Pitfalls

- **Height Maps:** Use **OpenEXR (.exr)** or **RAW (.r16)**. Avoid 8-bit PNG to prevent "stairs" artifacts.
- **Runtime Loading:** Use `CACHE_MODE_IGNORE` when loading `.tres` assets via code.
- **Unused Slots:** Empty texture slots consume VRAM (~1k each). Remove if not needed.
- **Normal Map Setting:** Always set `Normal Map` to **Disabled** in Godot's Import tab for terrain textures.
- **Sentinel Constants:** Do NOT assume constants like `INVALID_LOCATION` exist in `Terrain3DData`. Always check `get_region()` results for `null`.

### Direct Image Access (Bulk Updates)
For procedural generation or bulk painting, avoid point-by-point API calls. Instead, use direct Image pixel access:

```gdscript
for region in terrain.data.get_regions_active():
    var ctrl_img: Image = region.get_map(Terrain3DRegion.TYPE_CONTROL)
    var h_img:    Image = region.get_map(Terrain3DRegion.TYPE_HEIGHT)
    
    for x in region.region_size:
        for y in region.region_size:
            var h: float = h_img.get_pixel(x, y).r
            # ... compute logic ...
            var bits: int = Terrain3DUtil.enc_base(id) | Terrain3DUtil.enc_auto(true)
            ctrl_img.set_pixel(x, y, Color(Terrain3DUtil.as_float(bits), 0, 0, 1))

    region.set_modified(true)
    region.set_edited(true)

terrain.data.update_maps(Terrain3DRegion.TYPE_CONTROL, false)
```

## 11. Cliff-Only Autoshading

This advanced technique delegates cliff texturing to the GPU while keeping manual or height-based control over flat terrain. It is the primary strategy for the `TerrainManager`.

### How it Works
1. **Generator Logic**: The `TextureMapGenerator` calculates the slope for every pixel.
2. **Tagging**: If the slope exceeds the `slope_threshold`, the generator sets the **"Auto" flag** bit on that pixel in the Control Map.
3. **GPU Rendering**: When the shader sees the "Auto" flag is `ON`, it ignores the specific texture IDs assigned by the generator and instead uses the global slope-blending rules defined in the material.

### Configuration Steps
To enable this in your project:

1. **Material Setup**: Open `res://assets/terrain3d/terrain_material.tres`:
   - Set **Auto Shader** = `Enabled`.
   - Set **Auto Base Texture** = `4` (Rock / Steep).
   - Set **Auto Overlay Texture** = `0` (Grass / Flat).
   - Set **Auto Slope** = `0.5` (Adjusts the blend sharpness on the cliff face).

2. **Generator Setup**: In the `TerrainManager` scene:
   - Ensure the `TextureMapGenerator` has a `slope_threshold` (e.g., `35.0`).
   - Run the generator via the **"Generate Texture Map"** tool button.

3. **Validation**: 
   - Areas flatter than the threshold will respect your `HeightZones`.
   - Areas steeper than the threshold will automatically transition into the cliff rock texture.

### Runtime Generation & Region Management
Terrain3D allows for dynamic world expansion. Since it is region-based (default 1024x1024 chunks), you can add and populate terrain as the player moves.

#### Automatic Creation
If `import_images()` is called with a position where no region currently exists, **Terrain3D will automatically create the required regions** to accommodate the image data.

```gdscript
func generate_noise_terrain(terrain: Terrain3D):
    var noise := FastNoiseLite.new()
    noise.frequency = 0.0005
    
    # Create a 2048x2048 image for two 1024 regions
    var img: Image = Image.create_empty(2048, 2048, false, Image.FORMAT_RF)
    for x in img.get_width():
        for y in img.get_height():
            var val = noise.get_noise_2d(x, y)
            img.set_pixel(x, y, Color(val, 0, 0, 1))
            
    # This call automatically creates regions if they don't exist
    # [height_map, control_map, color_map], global_pos, offset, scale
    terrain.data.import_images([img, null, null], Vector3(-1024, 0, -1024), 0.0, 150.0)
```

#### Manual Region Management (Streaming)
For infinite or streamed worlds, use the following methods to manage regions explicitly:

- **`terrain.data.has_region(location: Vector2i)`**: Checks if a region exists at the grid coordinate.
- **`terrain.data.add_region(world_pos: Vector3)`**: Snaps to the grid and creates a blank region.
- **`terrain.data.remove_region(region: Terrain3DRegion)`**: Unloads a region from memory.

**Streaming Pattern Example:**
```gdscript
func update_streaming(player_pos: Vector3):
    var loc: Vector2i = terrain.data.get_region_location(player_pos)
    if not terrain.data.has_region(loc):
        terrain.data.add_region(player_pos)
        # Populate new region...
        terrain.data.update_maps(Terrain3DRegion.TYPE_MAX, false)
```

### Runtime Navigation
Terrain3D provides specialized functions to generate geometry for navigation baking.
```gdscript
func bake_nav_mesh(nav_mesh: NavigationMesh, terrain: Terrain3D, aabb: AABB):
    var source_geometry = NavigationMeshSourceGeometryData3D.new()
    # Generate faces from terrain for the given AABB
    var faces: PackedVector3Array = terrain.generate_nav_mesh_source_geometry(aabb, false)
    source_geometry.add_faces(faces, Transform3D.IDENTITY)
    NavigationServer3D.bake_from_source_geometry_data(nav_mesh, source_geometry)
```
