# Terrain Manager

> **Status:** Draft
> **Created:** 2026-05-05
> **Last Updated:** 2026-05-07

## Overview

The `TerrainManager` is the centralized architectural hub for all terrain-related operations in the project. It encapsulates the `Terrain3D` system, providing a high-level interface for terrain generation, modification, and data management.

## Architecture

The system follows a scene-based encapsulation pattern:

- **Scene:** `res://scenes/TerrainManager.tscn`
- **Script:** `res://scripts/TerrainManager.gd`
- **Root Node:** `TerrainManager` (Node3D)
- **Primary Child:** `Terrain3D` (Terrain3D)

### Scene Structure
```
TerrainManager (Node3D) [TerrainManager.gd]
├── Terrain3D (Terrain3D)
├── HeightMapGenerator (Node) [HeightMapGenerator.gd]
└── TextureMapGenerator (Node) [TextureMapGenerator.gd]
```

## AI-Automated CLI Import Workflow

For rapid asset integration, an automated pipeline exists for the AI Agent to import PBR textures directly from the command line.

### Utility Script
- **Path:** `res://scripts/util/cmd_import_texture.gd`
- **Type:** `EditorScript` (@tool)
- **Purpose:** Packs PBR source files (Albedo, Height, Normal, Roughness) into RGBA PNGs and updates `res://assets/terrain3d/terrain_assets.tres`.

### Automated Execution Procedure
When the AI Agent is asked to import a texture, it follows these steps:
1.  **Configure:** Use the `replace` tool to inject source paths into the `CONFIGURATION` constants of the script.
2.  **Execute:** Run the following command headlessly:
    ```powershell
    godot --headless --path src/feudal-age -s scripts/util/cmd_import_texture.gd
    ```
3.  **Validate:** Verify the success message and the presence of new PNGs in `res://assets/terrain3d/textures/`.

## Core Responsibilities

1.  **Encapsulation:** Wraps the `Terrain3D` node to prevent "leaking" plugin-specific complexity into the rest of the game logic.
2.  **Data Management:** Configures and maintains the `data_directory` (default: `res://assets/terrain3d/data`) for high-precision heightmaps and control maps.
3.  **Asset Handling:** Manages the assignment of `Terrain3DAssets` and `Terrain3DMaterial`. **Note:** These should always be saved as standalone `.tres` files in `res://assets/terrain3d/` to avoid scene file bloat and enable sharing.
4.  **Editor Integration:** Provides custom inspector tools for developers to trigger terrain updates or generation without needing to run the full game.
5.  **Runtime API:** Acts as the primary interface for other systems (e.g., building system, weather system) to query terrain height or normal data.

## Specifications & Conventions

-   **World Scale:** The project follows a **1 unit = 1 meter** convention. All terrain dimensions, heightmap scales, and asset sizes are based on this metric.
-   **Coordinate System:** Uses Godot's standard Y-up, right-handed coordinate system.
-   **Resolution:** The default target resolution for terrain is **0.25 meters per vertex**, achieved by adjusting the `mesh_scale` or vertex spacing of the `Terrain3D` node.
-   **Demo Folder Policy:** The `demo/` folder is a self-contained plugin example. Do NOT modify it or reference its assets from the main project. Use `res://assets/terrain3d/` for all game-related resources.

## Inspector Interface

The `TerrainManager` uses `@tool` mode to expose functionality directly in the Godot Inspector.

-   **Generate Terrain Button:** A tool button labeled "Generate Terrain" on the root `TerrainManager` node that executes the following sequence:
    1.  Triggers `HeightMapGenerator.generate()` to sculpt the surface.
    2.  Triggers `TextureMapGenerator.generate()` to paint the surface based on the new heights.

## Heightmap Generator

The `HeightMapGenerator` is a modular child node responsible for procedurally sculpting the terrain surface.

### Parameters

-   **Min Height / Max Height:** Defines the vertical range of the terrain in meters.
-   **Frequency:** Controls the density of the noise. Lower values create rolling hills; higher values create jagged, dense peaks.
-   **Noise Scale:** Multiplier for the sampling distance. Increasing this "stretches" the noise, making hills wider and further apart.
-   **Noise Seed:** The seed for the `FastNoiseLite` generator, allowing for reproducible terrain shapes.

### Technical Implementation

-   **Algorithm:** Uses `FastNoiseLite` with the `PERLIN` noise type.
-   **Data Format:** Generates height data into a Godot `Image` using the `FORMAT_RF` (32-bit Red-only float) format. This ensures maximum precision and prevents "terracing" or "stepping" artifacts.
-   **Integration:** Updates the terrain using the `terrain.data.import_images()` method, which is the most performant way to apply large-scale height changes.
-   **Spatial Alignment:** Currently generates a 2048x2048 vertex area. At 0.25m resolution, this produces a **512m x 512m** terrain area, centered at `Vector3(-256, 0, -256)`. This spans four Terrain3D regions (each 1024x1024 vertices).

### How to Use

1.  Select the **HeightMapGenerator** node in the scene tree.
2.  Adjust the **Height** and **Noise** settings in the Inspector.
3.  Click the **Generate Heightmap** button.
4.  Alternatively, click **Generate Terrain** on the root **TerrainManager** node to trigger the generator.

## Texture Map Generator

The `TextureMapGenerator` is a modular child node responsible for automatically painting the terrain surface based on elevation and slope.

### Parameters

-   **Height Zones:** An array of `HeightZone` resources. Each zone defines a texture to apply within a specific elevation range.
    -   **Label:** A descriptive name for the zone (e.g., "Deep Water", "Meadow").
    -   **Texture ID:** The slot index (0–31) in the `Terrain3DAssets` library.
    -   **Min Height / Max Height:** The elevation range in meters where this texture is applied.
-   **Blend Width:** The width of the cross-fade region (in meters) between adjacent height zones. Transitions are centered on the zone boundaries.
-   **Slope Threshold:** The angle (in degrees from vertical) above which the terrain is automatically marked for the **Autoshader**. This allows for steep cliffs to use a different shading path (e.g., rock faces).

### Technical Implementation

-   **Algorithm:** Iterates through all active terrain regions. For each vertex, it reads the height, calculates the local slope (central difference), and determines the appropriate texture indices and blend factor.
-   **Data Format:** Writes directly to the `Terrain3D` **control map** using packed `uint32` values. It utilizes `Terrain3DUtil` for bitwise encoding of base textures, overlay textures, and blend weights.
-   **Performance:** Uses direct `Image` pixel access for bulk generation, significantly faster than point-by-point API calls.
-   **API:** Provides `generate_at(world_pos)` for targeted updates of a single terrain region.

### How to Use

1.  Select the **TextureMapGenerator** node in the scene tree.
2.  In the **Height Zones** array, add one or more elements.
3.  For each element, click the drop-down and select **"New HeightZone"**.
4.  Configure the `Label`, `Texture ID`, and `Height` range for each zone.
5.  Adjust the **Blend Width** and **Slope Threshold** as needed.
6.  Click the **Generate Texture Map** button. (The `terrain` property is automatically discovered if the node is a child of `TerrainManager`).
7.  Alternatively, click **Generate Terrain** on the root **TerrainManager** node to trigger both height and texture generation.

### TODOs

- The Terrain3D node refrence is exported. It should be programmatically set by the script just like it is in the `HeightMapGenerator`.

## Programmatic Usage

To interact with the terrain, other systems should reference the `TerrainManager` instance.

### Resource Assignment
At runtime, resources must be loaded explicitly, typically using `CACHE_MODE_IGNORE` to avoid cleared VRAM caches:
```gdscript
func setup_terrain():
    var terrain = terrain_manager.terrain
    terrain.assets = ResourceLoader.load("res://assets/terrain3d/terrain_assets.tres", "", ResourceLoader.CACHE_MODE_IGNORE)
    terrain.material = load("res://assets/terrain3d/terrain_material.tres")
    terrain.data_directory = "res://assets/terrain3d/data"
```

### Data Queries
```gdscript
# Get height at a specific position
var height = terrain_manager.terrain.data.get_height(global_pos)

# Trigger a manual generation (from script or button)
terrain_manager.generate_terrain()
```

## Development Plan

This plan outlines the phased approach for implementing the terrain system. Each phase requires research, detailed planning, and architectural decisions before implementation.

### Phase 0: Cleanup & Migration
- **Status:** Completed
- **Goal:** Switch from legacy `hterrain` to `Terrain3D`.
- **Tasks:**
    - Update documentation to reflect `Terrain3D` usage.
    - Retain legacy `hterrain` notes but clearly mark them as legacy.
    - Remove the `hterrain` plugin from the project.

### Phase 1: Basic Implementation
- **Status:** Completed
- **Goal:** Establish the core `TerrainManager` scene.
- **Specifications:**
    - Scale: 1 unit = 1 real-world meter.
    - Area: Initial focus on a 100x100 meter tile.
    - Resolution: 0.25 meters per vertex.

### Phase 2: Heightmap Generator
- **Status:** Completed
- **Goal:** Procedural heightmap generation using noise.
- **Tasks:**
    - Create a child generator node/script (`HeightMapGenerator.gd`).
    - Implement `FastNoiseLite` integration with `PERLIN` noise.
    - Expose `export_tool_button` for editor-time generation.
    - Implement programmatic API for runtime generation using `Image.FORMAT_RF`.
    - Inspector controls: Min/Max height, `Frequency`, and `Noise Scale`.

### Phase 3: Material Creation
- **Status:** Completed
- **Goal:** Asset integration and material configuration.

### Phase 4: Splatmap Generator
- **Status:** Completed
- **Goal:** Height-based automatic texturing (Implemented as `TextureMapGenerator`).
- **Tasks:**
    - Implement a script to create splatmaps based on heightmap data.
    - Support smoothing/blending between height zones.
    - Expose editor and programmatic triggers.

### Phase 4.5: helper scripts
- Write a helper script that can instantiate a terrain-manager scene in another scene heirachy

### Phase 5: Mesh Asset Configuration
- **Goal:** Vegetation and foliage asset definition.
- **Tasks:**
    - Analyze `meadow` assets for suitable foliage.
    - Define `Terrain3DMeshAsset` resources on the terrain.

### Phase 6: Vegetation Map Generator
- **Goal:** Procedural foliage distribution.
- **Tasks:**
    - Use noise algorithms to distribute assets chaotically but evenly.
    - Tie placement to materials/height.
    - Implement `AddTree` and `RemoveTree` utility functions.
    - Logic for painting "leaves" material on the splatmap around trees.

### Phase 7: Navigation
- **Goal:** Pathfinding integration.
- **Tasks:**
    - Research `Terrain3D` built-in navigation capabilities.
    - Create a generator to produce `NavigationRegion3D` geometry.
    - Ensure the navmap is queryable by external agents.

### Phase 8: Biomes & Voronoi Diagrams
- **Goal:** Large-scale world organization.
- **Tasks:**
    - Implement a root-level Biome Generator.
    - Use Voronoi diagrams to partition terrain regions.
    - Designate regions (e.g., forests) and trigger vegetation generation within them.
    - Inspector controls for region counts and forest density.
 vegetation generation within them.
    - Inspector controls for region counts and forest density.
