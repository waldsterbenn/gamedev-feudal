---
name: ambientcg-polyhaven
description: CC0-licensed asset libraries providing high-quality PBR materials, HDRIs,
  and 3D models for commercial and personal use without attribution.
license: CC0 (no attribution required)
compatibility: Godot 4.x, Feudal Game project
metadata:
  license: CC0 (no attribution required)
tags:
- godot
- plugin
- feudal-game
---

# AmbientCG & Polyhaven

**Websites:**
- https://ambientcg.com (PBR materials, HDRIs, models)
- https://polyhaven.com (HDRIs, textures, 3D models)

### What They Are
CC0-licensed asset libraries providing high-quality PBR materials, HDRIs, and 3D models for commercial and personal use without attribution.

### AmbientCG Features
- **2840+ assets** (as of research date)
- **PBR Surfaces:** Materials, atlases, decals
- **HDRIs:** Environment lighting (8k-16k resolution)
- **Substances:** Procedural material definitions
- **3D Models:** Scan-based and modeled assets
- **Formats:** PNG, EXR, GLTF, BLEND, USDZ
- **License:** CC0 (no attribution required)

### Polyhaven Features
- **HDRIs:** 16k+ resolution, unclipped for realistic lighting
- **Textures:** Photoscanned seamless PBR materials (8k+)
- **Models:** Hyperreal 3D models for VFX/games
- **Vaults:** Patreon-exclusive asset collections
- **License:** CC0 (completely unrestricted)

### Installation/Usage
**Texture Workflow:**
1. Download desired texture set (usually includes albedo, normal, roughness, metallic, displacement)
2. Import PNG/EXR files into Godot's `res://textures/` folder
3. Create `StandardMaterial3D` and assign texture maps
4. Configure UV scaling and triplanar mapping if needed

**HDRI Workflow:**
1. Download EXR HDRI file
2. Create `WorldEnvironment` node
3. Add `Sky` resource with `PanoramaSkyMaterial`
4. Assign HDRI as panorama texture
5. Adjust exposure and rotation

**3D Model Workflow:**
1. Download GLTF/GLB files
2. Import into Godot scene
3. Adjust material properties
4. Set up LOD if needed

### Code Example
```gdscript
# Applying an AmbientCG material programmatically
var material = StandardMaterial3D.new()
material.albedo_texture = preload("res://textures/ambientcg/ground_albedo.png")
material.normal_texture = preload("res://textures/ambientcg/ground_normal.png")
material.roughness_texture = preload("res://textures/ambientcg/ground_roughness.png")
material.metallic_texture = preload("res://textures/ambientcg/ground_metallic.png")

$MeshInstance3D.material_override = material

# Setting up Polyhaven HDRI
var sky = Sky.new()
var sky_material = PanoramaSkyMaterial.new()
sky_material.panorama = preload("res://hdris/polyhaven/sunset.exr")
sky.sky_material = sky_material

var world_env = WorldEnvironment.new()
world_env.environment = Environment.new()
world_env.environment.sky = sky
add_child(world_env)
```

### Integration Notes
- Both sites offer bulk download options
- Consider texture compression for mobile targets
- HDRIs may need tone mapping adjustment for Godot's renderer
- Some assets include displacement maps requiring vertex subdivision
