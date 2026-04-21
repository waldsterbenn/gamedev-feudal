---
name: hterrain
description: A high-performance heightmap-based terrain system implemented entirely
  in GDScript, featuring texture painting, LOD, grass rendering, and extensive...
license: MIT (assumed)
compatibility: Godot 4.x, Feudal Game project
metadata:
  repository: https://github.com/Zylann/godot_heightmap_plugin
  maintainer: Zylann
  version: Master branch (Godot 4.1+), Godot 3.x branch available
  license: MIT (assumed)
  documentation: https://hterrain-plugin.readthedocs.io/
tags:
- godot
- plugin
- feudal-game
---

# HTerrain (Heightmap Terrain Plugin)
**Repository:** https://github.com/Zylann/godot_heightmap_plugin
**Documentation:** https://hterrain-plugin.readthedocs.io/
**Maintainer:** Zylann
**Version:** Master branch (Godot 4.1+), Godot 3.x branch available
**License:** MIT (assumed)

### What It Is
A high-performance heightmap-based terrain system implemented entirely in GDScript, featuring texture painting, LOD, grass rendering, and extensive editor tools.

### How It Works
HTerrain uses Godot's `VisualServer` API to create terrain meshes from heightmap data, supporting:
- **Heightmap Sculpting:** Brush-based terrain editing
- **Texture Painting:** Multi-layer PBR material painting
- **Detail Layers:** Grass, rocks, and foliage scattering
- **LOD System:** Automatic level-of-detail for performance
- **Hole Painting:** Create caves and openings
- **Procedural Generation:** Built-in noise-based terrain generation

### Installation
**Automatic (Asset Library):**
1. Go to Asset Library tab in Godot
2. Search for "HTerrain" or "Zylann"
3. Download and install
4. Enable in Project Settings → Plugins

**Manual:**
1. Download from GitHub or Asset Library (asset #231)
2. Extract `addons/zylann.hterrain` to project root
3. Enable plugin in Project Settings

**Development Version:** Clone master branch for latest features (potentially unstable)

### Basic Usage
```gdscript
# Creating terrain programmatically
var terrain = HTerrain.new()
terrain.heightmap_resolution = 513
terrain.heightmap_scale = Vector3(100, 50, 100)
add_child(terrain)

# Loading heightmap data
var image = Image.load_from_file("res://heightmap.png")
terrain.set_heightmap_data(image)

# Adding texture layers
var ground_texture = preload("res://textures/ground_albedo.png")
terrain.add_texture_layer(ground_texture, 0)
```

### Editor Workflow
1. Add `HTerrain` node to scene
2. Use Terrain toolbar to sculpt/paint textures
3. Configure detail layers for grass/foliage
4. Bake navigation mesh for AI pathfinding
5. Adjust LOD settings for performance

### Performance Considerations
- Entirely GDScript-based (no GDExtension dependencies)
- Uses `VisualServer` for efficient rendering
- LOD system maintains high FPS with large terrains
- Detail layers use GPU instancing

**Demo Project:** https://github.com/Zylann/godot_hterrain_demo
