---
name: terrain3d
description: A high-performance, GDExtension-based terrain system designed for large-scale environments in Godot 4.
license: MIT
compatibility: Godot 4.x, Feudal Game project
metadata:
  repository: "https://github.com/TokisanGames/Terrain3D"
  maintainer: "TokisanGames"
  version: "Godot 4.x"
  license: "MIT"
tags:
  - godot
  - plugin
  - feudal-game
---

## 10. Terrain3D
**Repository:** https://github.com/TokisanGames/Terrain3D
**Maintainer:** TokisanGames
**Version:** Godot 4.x
**License:** MIT

### What It Is
A high-performance, GDExtension-based terrain system designed for large-scale environments in Godot 4. It uses GPU-driven mesh processing and is written in C++.

### Key Features
- **Massive Scale:** Supports terrains from 64x64m up to 65.5x65.5km.
- **High Performance:** GPU-driven geometric clipmap mesh with up to 10 LOD levels.
- **Editing Tools:** In-editor sculpting, painting (textures, colors, wetness), and hole cutting.
- **Texture System:** Supports up to 32 texture sets with detiling and auto-shading.
- **Foliage Instancing:** Built-in foliage system with LODs and shadow impostors.
- **Compatibility:** Full GDScript and C# support.

### Installation
1. Download the release from GitHub.
2. Extract the `addons/terrain_3d` folder to your project's `addons/` directory.
3. Enable the plugin in Project Settings -> Plugins.

### Core Nodes & Resources
- **`Terrain3D`**: Main node managing rendering, collision, and tools.
- **`Terrain3DAssets`**: Resource managing **Textures** and **Meshes** (foliage).
- **`Terrain3DTextureAsset`**: Individual texture definition (Albedo + Height in Alpha, Normal + Roughness in Alpha).
- **`Terrain3DMeshAsset`**: Foliage mesh definition for the instancer.
- **`Terrain3DStorage`**: Container for all terrain data (Height, Control, Color).

### Programmatic Usage (GDScript)
```gdscript
# Get height at global position
var height = terrain.data.get_height(global_pos)

# Get normal at global position
var normal = terrain.data.get_normal(global_pos)

# Runtime editing
terrain.data.set_height(global_pos, 10.0)
terrain.data.set_color(global_pos, Color.GREEN)
terrain.data.force_update_maps() # Sync changes to GPU
```

### Advanced: Runtime Navigation
Terrain3D provides specialized functions to generate geometry for navigation baking.
```gdscript
func bake_nav_mesh(nav_mesh: NavigationMesh, terrain: Terrain3D, aabb: AABB):
    var source_geometry = NavigationMeshSourceGeometryData3D.new()
    # Generate faces from terrain for the given AABB
    var faces: PackedVector3Array = terrain.generate_nav_mesh_source_geometry(aabb, false)
    source_geometry.add_faces(faces, Transform3D.IDENTITY)
    NavigationServer3D.bake_from_source_geometry_data(nav_mesh, source_geometry)
```
