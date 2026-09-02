---
status: open
type: research
blocked-by: []
---

# Audit Terrain3D state — is the world actually rendered?

## Question

`World.tscn` references `res://scenes/TerrainManager.tscn` and instantiates `Player.tscn` at a specific transform. `TerrainManager.tscn` references `terrain_3d` (the addon). But:

1. **Has `terrain_data/` been generated?** There's a `src/feudal-age/terrain_data/` directory referenced in the README — what's in it?
2. **Was `HeightMapGenerator.gd` / `TextureMapGenerator.gd` ever run?** There are Python and GDScript generators in `src/feudal-age/scripts/terrainmanager/`.
3. **Is Terrain3D's plugin enabled?** Project's `project.godot` shows `enabled=PackedStringArray("res://addons/terrain_3d/plugin.cfg")`.
4. **What happens on first headless boot?** Does Terrain3D complain about missing heightmap, or just render an empty terrain?
5. **Are the spawn positions in `WorldInitializer.gd`** (e.g. `Vector3(12.0, 79.129, 12.0)`) actually on terrain, or floating in space because terrain hasn't been generated?

Output target: `docs/wayfinder/findings/05-audit-terrain3d-state.md` — a short report with: what's in terrain_data/, whether the generators ran (and how to run them), what the headless boot output looks like, and whether player/NPC/zone spawn positions are sane.

This MUST complete before the headless-boot prototype ticket, because "first headless boot" can't be diagnosed if the terrain is broken.