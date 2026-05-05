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

# Runtime surgical editing
terrain.data.set_height(global_pos, 10.0)
terrain.data.set_color(global_pos, Color.GREEN)
terrain.data.force_update_maps() # Sync changes to GPU
```

### Heightmap Generation & Import
Terrain3D uses a region-based system (default 1024x1024). For large updates or noise-based generation, use `import_images`.

#### Recommended Formats
- **OpenEXR (.exr):** **Best Choice.** Use 16-bit or 32-bit float. Godot imports these as high-precision data, avoiding "stairs" artifacts.
- **RAW (.r16):** 16-bit unsigned integer. Standard export from tools like WorldMachine/Gaea.
- **Avoid PNG:** Standard 8-bit PNGs lack resolution (256 levels), causing visible stepping.

#### Runtime Noise Generation
Use `Image.FORMAT_RF` (32-bit Red channel float) for heightmaps.
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
            
    # Import into storage
    # [height_map, control_map, color_map]
    # offset: where to place the top-left corner
    # scale: vertical multiplier for the height data
    terrain.data.import_images([img, null, null], Vector3(-1024, 0, -1024), 0.0, 150.0)
```

### Tips & Best Practices
- **Region Stitching:** Terrain3D uses a 1025x1025 internal mesh for 1024x1024 regions to ensure perfect stitching. When importing, ensure your data covers the full range.
- **Performance:** Use `import_images` for bulk changes (e.g., initial generation or massive terraforming). Use `set_height` for continuous local edits (e.g., character footsteps, small craters).
- **Collision:** For runtime generated terrain, ensure collision is updated. In Godot 4, you may need to toggle `collision_enabled` or use `terrain.collision.mode = Terrain3DCollision.DYNAMIC_EDITOR` for immediate updates.
- **Texture Packing:** 
    - **Albedo + Height:** Height data for textures should be in the Alpha channel of the Albedo map.
    - **Normal + Roughness:** Roughness should be in the Alpha channel of the Normal map.
- **Precision:** Always use 16-bit or 32-bit floats for heightmaps to maintain smooth slopes.

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
