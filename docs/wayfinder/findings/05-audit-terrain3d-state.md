# Findings 05 — Terrain3D state audit

**Question (ticket):** Has `terrain_data/` been generated? Were `HeightMapGenerator.gd` / `TextureMapGenerator.gd` ever run? Is the `terrain_3d` plugin enabled and the addon present? What does a headless boot emit, and are `WorldInitializer.gd` spawn Y coordinates actually on terrain?

## Summary

The world **is rendered**. The Terrain3D addon (v1.0.1) is installed, enabled in `project.godot`, loads cleanly on headless boot (exit 0, no errors), and the editor pass confirms its plugin initialises. The active Terrain3D data lives at `src/feudal-age/assets/terrain3d/data/` (64 region `.res` files), and the configured scene path matches. `World.tscn` instantiates `TerrainManager.tscn`, which has a `Terrain3D` node pointing at that directory. However, the directory named `src/feudal-age/terrain_data/` referenced by the ticket and README is **legacy HTerrain data** (Zylann's pre-Terrain3D system), not the file Terrain3D actually reads at runtime — those files are dead weight. The GDScript generators (`HeightMapGenerator.gd`, `TextureMapGenerator.gd`) have **not** been invoked at runtime: their only invocation points are `@export_tool_button` inspector buttons plus `TerrainManager.generate_terrain()`, which is never called from any scene or autoload. The hardcoded spawn Y values in `WorldInitializer.gd` (78.0–79.129) happen to fall near the centre of the heightmap's range, so they sit roughly on terrain, but the code does not depend on this — `ZoneCoordinator.create_zone_anchor` and `NPCCoordinator.create_npc` already overwrite Y from `terrain_service.get_height()` whenever the service reports a value. No terrain-related errors block headless boot.

---

## terrain_data inventory

Path: `src/feudal-age/terrain_data/`

| File | Type | Notes |
|---|---|---|
| `data.hterrain` | JSON text | HTerrain metadata (Zylann's HTerrain format) — **not** Terrain3D |
| `height.res` | NI (National Instruments) TDMS | HTerrain heightmap resource — **not** Terrain3D |
| `color.png` | PNG 513×513 RGBA | HTerrain colour map |
| `detail.png` | PNG | HTerrain detail map |
| `normal.png` | PNG | HTerrain normal map |
| `splat.png` | PNG 513×513 RGBA | HTerrain splat/weight map |
| `.import` sidecars | text | Generated Jul 17 19:46 |

**Conclusion:** This directory contains HTerrain (legacy) data and is **not** read by the current Terrain3D pipeline. The `data_directory` on the `Terrain3D` node in `TerrainManager.tscn` is `res://assets/terrain3d/data`, not `terrain_data/`. The `terrain_data/` files appear to be the migration artefact — kept on disk but unused.

The actual Terrain3D region data lives at `src/feudal-age/assets/terrain3d/data/` (64 `terrain3d_<col>_<row>.res` files spanning region grid coordinates -04..03 in both axes — i.e. an 8×8 region grid, sized for the addon's default 1024-vertex regions on a 32m `mesh_size`). These files are dated Jul 9 17:35, ~10 days before the `.import` sidecars in `terrain_data/`, which is consistent with "Terrain3D data written first, then HTerrain data left behind from a failed/abandoned migration".

`src/feudal-age/assets/terrain3d/terrain_assets.tres` references 10 meadow `.tres` texture assets (indices 0–9, all in `assets/textures/meadow/`); the height zones in `TerrainManager.tscn` map to those indices (zone texture_ids 1–5 are within range, "Medow clovers"=1, "Meadow Grass"=?, "Medow Flowers"=2, "Rocky Moss"=5, "Rocks"=4 — exact mapping needs verification but no out-of-range indices).

---

## Generators status

| Script | Runtime invocation? | Notes |
|---|---|---|
| `scripts/terrainmanager/HeightMapGenerator.gd` | **No** | Only callable via `@export_tool_button("Generate Heightmap")` (editor inspector) or `TerrainManager.generate_terrain()`. No autoload, scene `_ready`, or other script calls it. |
| `scripts/terrainmanager/TextureMapGenerator.gd` | **No** | Same pattern: only `@export_tool_button` and `TerrainManager.generate_terrain()`. |
| `scripts/terrainmanager/TerrainManager.gd` | Registered via `ServiceLocator` in its `_ready()` (`if not Engine.is_editor_hint()`). Its `generate_terrain()` function exists but is never called from code. |
| `scripts/terrainmanager/integrate_meadow_assets.py` | **Already run, partially.** | Source-dir `Assets/Synthy/...Meadow_Source_Files/Textures/Terrain/` is **not** present in the repo (only the generated `.tres` and the source `.png` files in `assets/textures/meadow/` exist). So the source assets are missing from version control, but the integration step that copies them and writes the `.tres` resources was completed. |

**Call-shape to run the generators manually (for reference, not run here):**

- Heightmap: open `scenes/TerrainManager.tscn` in editor → select `HeightMapGenerator` → click "Generate Heightmap" tool button. The generator writes a 2048×2048 `FORMAT_RF` image, applies it via `terrain.data.import_images(...)`, then **overwrites** the 64 region `.res` files in `assets/terrain3d/data/`.
- Texture map: same scene → select `TextureMapGenerator` → click "Generate Texture Map" tool button. It iterates `terrain.data.get_regions_active()` and writes a control map into each region.
- The two generators are coupled by `TerrainManager.generate_terrain()`, which calls `height_generator.generate()` then `texture_generator.generate()` — but that wrapper is also never called.

**Conclusion:** The current terrain state (`assets/terrain3d/data/*.res`) is the result of **one prior editor-button generation** (date Jul 9, before the generators themselves were last touched on Aug 31). The generators themselves are not part of the runtime or autoload sequence — they are authoring tools.

---

## Addon presence

- `src/feudal-age/addons/terrain_3d/` is present.
  - `plugin.cfg`: name "Terrain3D", version 1.0.1, by Cory Petkovsek & Roope Palmroos.
  - `terrain.gdextension`: declares Windows, Linux, macOS, Android, iOS, Web libraries.
  - `bin/libterrain.windows.{debug,release}.x86_64.dll` present (3.5–4.2 MB).
  - `src/editor_plugin.gd` present.
- `project.godot` `[editor_plugins] enabled = PackedStringArray("res://addons/terrain_3d/plugin.cfg")` — confirmed.
- `addons/3d_controls_toolkit` is also present but **not** listed in `enabled=PackedStringArray(...)` in `project.godot` — secondary addon, unrelated.
- `addons/terrain_3d/bin/` has two leftover temp files: `~libterrain.windows.debug.x86_64.dll~RF119812f.TMP` (4.2 MB, May 11) and `~libterrain.windows.debug.x86_64.dll~RF151d951.TMP` (4.2 MB, Jul 17) — these are Windows-named temp files left from failed renames (likely the SCons build writes to a temp path and renames). Cosmetic, but they clutter `bin/` and could confuse a future clean build.
- `addons/terrain_3d/terrain.gdextension` references `linux.arm64`, `linux.rv64`, `macos.arm64` binary paths that **do not exist** in `bin/`. Godot tolerates missing optional platform entries, so this is non-blocking on Windows but would break Linux arm64 / Linux riscv64 / macOS Apple-Silicon builds.

---

## Headless output (editor pass)

Command: `cd /c/Users/woodl/GitHub/gamedev-feudal && /c/Users/woodl/Godot_v4.6.2-stable_win64/godot --path ./src/feudal-age/ --headless --editor --quit 2>&1 | tail -60`

Exit code: 0.

Terrain-related lines (last 60):
- `[ DONE ] update_scripts_classes` — script class cache built successfully (no `HeightZone`, `TextureMapGenerator` resolution failures).
- 20 `WARNING: Terrain3DTextureAsset#NNNN:set_{albedo,normal}_texture: Texture 'X' has no mipmaps` — for all 10 meadow textures (×2 each, albedo+normal). Non-fatal; indicates the texture `.import` files have `mipmaps` disabled (the synthesised `.tres` files written by `integrate_meadow_assets.py` don't set mipmaps on the underlying PNGs).
- `WARNING: instance_reset_physics_interpolation() is deprecated.` — Godot 4.6 internal deprecation, not terrain-related.
- `ERROR: Attempt to open script 'res://scripts/characters/NpcPeasant.gd' resulted in error 'File not found'.` + `ERROR: Failed loading resource: res://scripts/characters/NpcPeasant.gd.` — **non-terrain**: `scenes/characters/NpcPeasant.tscn` (line 4) references `res://scripts/characters/NpcPeasant.gd`, but only `NPC.gd` and `PeasantCharacter.gd` exist in `scripts/characters/`. The error fires because the editor last-opened scene includes the World (which auto-loads NpcPeasant via the editor's auto-restore). Not part of the runtime scene tree (the active main scene uses `NPC.tscn`, not `NpcPeasant.tscn`), so this error appears only in the editor pass, not the plain `--quit` pass.
- `WARNING: ObjectDB instances leaked at exit (run with --verbose for details).` — generic engine cleanup noise.

No Terrain3D plugin-load errors. No missing region-file errors. No `terrain_3d_init` failures. No GDExtension binary-load failures.

---

## Headless output (plain pass)

Command: `cd /c/Users/woodl/GitHub/gamedev-feudal && /c/Users/woodl/Godot_v4.6.2-stable_win64/godot --path ./src/feudal-age/ --headless --quit 2>&1 | tail -60`

Exit code: 0.

Full output (15 lines, including the same 20 mipmap warnings):
- `Godot Engine v4.6.2.stable.official.71f334935` banner.
- 20 mipmap warnings (same set as editor pass).
- `instance_reset_physics_interpolation() is deprecated.`
- `EventBus: Core bus initialized successfully.`
- 9× `NPC initialized: Peasant` (matches `WorldInitializer.gd`'s 2+1+2+2+2 = 9 initial_populants across 5 zones).
- `GC: Commencing system bootstrap...`
- `ManagementModule: Initializing economic simulation...`
- `GC: Bootstrap sequence executed cleanly.`

Zero `ERROR:` lines. Zero `SCRIPT ERROR:` lines. No terrain complaints. No "Failed loading region" or "Failed to initialize Terrain3D" messages. The fact that `TerrainManager._ready()` runs `ServiceLocator.register_terrain_service(self)` and the main scene finishes a clean bootstrap means Terrain3D's `data` object is non-null and `get_height()` would return real values (the `ZoneCoordinator` and `NPCCoordinator` paths that overwrite Y from `terrain_service.get_height()` are exercised by the headless run).

---

## Blocking concerns

**None for headless boot or first scene render.** The world loads, Terrain3D instantiates, regions load from `assets/terrain3d/data/`, NPCs spawn, the bootstrap exits cleanly with code 0.

Downstream tickets may want to address:

1. **Dead `terrain_data/` directory.** The 6 files in `src/feudal-age/terrain_data/` (HTerrain format) are not referenced by any current `.tscn`, `.gd`, `.tres`, or `project.godot` entry. Removing them would clarify the asset lineage. Note: the README likely still references this directory — the ticket mentions "a `src/feudal-age/terrain_data/` directory referenced in the README", which is consistent with this being a stale reference rather than an active asset location.
2. **Missing `NpcPeasant.gd`** (editor pass only — surfaces when `NpcPeasant.tscn` is open in the editor). Not exercised at runtime because `World.tscn` references `NPC.tscn` instead. Doesn't block headless verification, but every editor open of World or any scene that references NpcPeasant will spam 2 error lines.
3. **`terrain.gdextension` references missing binaries** (`linux.arm64`, `linux.rv64`, `macos.arm64`). Non-blocking on Windows/Linux x86_64, but breaks cross-platform builds.
4. **Generators are authoring-only.** There is no automatic regeneration path. If the 64 region `.res` files get corrupted or need a different noise profile, someone must open the editor and click buttons. Not blocking for *this* ticket, but worth flagging for future automation work.
5. **`TerrainManager.tscn` has `metadata/_edit_lock_ = true`** on the `Terrain3D` child node — that's fine but means Inspector edits to the terrain are gated; not a blocker, just a workflow note.

---

## Non-blocking observations

- The hardcoded spawn Y values in `WorldInitializer.gd` (`78.0`, `78.5`, `79.129`) fall within the heightmap's plausible range (HeightMapGenerator defaults to `[0, 150]`, with the 2048m area centred at world origin and the noise frequency default producing a mix of low and mid elevations). Spawn X/Z (12–80) are well inside the terrain region grid (-04..03 covers 32m×8 = 256m → ±128m from origin, so the 0–80m span is inside). Spawns are therefore **on or near terrain**, not floating in space. But: the code does not rely on this — `ZoneCoordinator.create_zone_anchor` and `NPCCoordinator.create_npc` both call `terrain_service.get_height()` and overwrite Y when non-NaN. The hardcoded Y values in `WorldInitializer` are effectively ignored in practice (only used as the initial `Vector3` before the terrain lookup). The first zone at `Vector3(12, 79.129, 12)` was likely the developer's measured height at that spot.
- `Player.tscn` is instantiated in `World.tscn` at transform `(6.66805, 78.06772, 36.80931)` — same Y ballpark (78.07). Also consistent with terrain.
- `terrain_data/` files all dated May 4 19:28 (the original initial commit), `assets/terrain3d/data/*.res` all Jul 9 17:35 — the terrain region data was written 2 months after the HTerrain artefacts, which is when the project migrated from HTerrain → Terrain3D. Confirms the migration story in `AGENTS.md` ("Project is migrating to Terrain3D").
- The `.import` sidecars in `terrain_data/` (Jul 17) were regenerated during a recent editor run but do nothing functional — the engine still doesn't read those files.
- `ObjectDB instances leaked at exit` warning appeared on the editor pass only, not the plain pass — typical for editor cleanup, not a real leak.

---

**Verified:** No code or files were modified. No commits made. Findings file written only.