   # Deep Research Report: Godot Plugins for Feudal Game Development

   ## 1. 3D Controls Toolkit
   **Repository:** https://github.com/CiaNCI-Studio/3D-Controls-Toolkit
   **Maintainer:** Cianci Studio
   **Version:** 2.5 (Godot 4.5+)
   **License:** Unknown (repository doesn't specify)

   ### What It Is
   A comprehensive 3D camera/controller plugin providing four distinct control schemes:
   - First Person Controller
   - Third Person Controller
   - Side-Scrolling Controller
   - Top-Down Controller

   Designed as plug-and-play components that attach as children to `CharacterBody3D` nodes.

   ### How It Works
   The plugin consists of five main GDScript classes inheriting from `Node`:
   - `BaseControler3D.gd` – Base class with common functionality
   - `FirstPersonControler3D.gd` – First-person perspective with mouse look
   - `ThirdPersonControler3D.gd` – Third-person with orbit camera
   - `SideScrollingControler3D.gd` – 2.5D side-scrolling movement
   - `TopDownControler3D.gd` – Top-down/RTS-style movement

   Each controller automatically handles player input, camera management, and basic movement physics when attached to a character node.

   ### Installation
   1. Download the latest release or clone the repository
   2. Copy the `addons/3d_controls_toolkit` folder to your project's `addons/` directory
   3. Enable the plugin in Project Settings → Plugins
   4. Configure required input map actions (see below)

   ### Configuration
   **Required Input Actions:** `up`, `down`, `left`, `right`
   **Optional Actions:** `sprint`, `jump`

   **Key Configuration Properties:**
   - **General:** Player geometry reference, movement type (Move and Slide/Collide/None)
   - **Jump:** Height, time to peak/descend, variable jump, coyote time, jump buffer
   - **Movement:** Walk/sprint speeds, acceleration/deceleration, dash, wall climb, double jump
   - **First Person:** Mouse sensitivity, turn speed, camera angles, offsets
   - **Third Person:** Spring length, camera angles, look-at offsets
   - **Side-Scrolling:** Camera smoothing, boundary limits, look-at player
   - **Top-Down:** Action type (keyboard vs mouse-click), floor detection, camera angle

   ### Usage Example
   ```gdscript
   # Basic setup for a third-person character
   # 1. Create a CharacterBody3D node
   # 2. Add a MeshInstance3D for visualization
   # 3. Add ThirdPersonControler3D as a child
   # 4. Configure input actions in Project Settings

   # The controller automatically handles:
   # - WASD movement with camera-relative directions
   # - Mouse-based camera orbiting
   # - Jump mechanics (if configured)
   # - Sprint/run transitions
   ```

   **Insufficient Information:**
   - No detailed API documentation available
   - Limited code examples in repository
   - Unknown compatibility with Godot 4.6+
   - No clear licensing information

   ---

   ## 2. Humanizer
   **Repository:** https://github.com/NitroxNova/humanizer
   **Wiki:** https://github.com/NitroxNova/humanizer/wiki
   **Maintainer:** NitroxNova (ReignBowGames)
   **Version:** v2.1.2 (Godot 4.3), v3 in development (Godot 4.4+)
   **License:** Unknown (likely CC0 for assets)

   ### What It Is
   A 3D character creation system based on MakeHuman and MPFB2, allowing procedural generation of humanoid characters with extensive customization options.

   ### How It Works
   Humanizer consists of:
   - **Core Plugin:** Handles character generation, rigging, and animation retargeting
   - **Asset System:** Base human models, clothing, and body parts from MakeHuman
   - **Import Pipeline:** Converts MakeHuman assets (MHCLO, MHMAT, OBJ) to Godot-compatible formats
   - **Authoring Tools:** In-editor interface for character customization

   The system uses shape keys (over 1000+) for morph-based customization of weight, height, gender, race, and age.

   ### Installation (v2)
   1. Download v2.1.2 release from GitHub
   2. Extract and copy the `addons` folder to your project
   3. Enable both `Humanizer` and `HumanizerGlobal` plugins in Project Settings
   4. Reload the project if needed
   5. Test with `addons/humanizer/scenes/tests/character3d.tscn`

   ### Version Compatibility
   | Godot Version | Humanizer Version | Branch       |
   |---------------|-------------------|--------------|
   | 4.3           | v2.x              | main         |
   | 4.4+          | v3 (dev)          | Requires separate assets |

   **v3 Architecture:** Separate import plugin, authoring plugin, and asset repository (`humanizer_assets`)

   ### Key Features
   - Fully customizable character weight/height/gender/race/age
   - 1000+ shape keys for unique character generation
   - Mixamo animation compatibility with retargeted rigs
   - Facial mocap capability on standard rig
   - Bone-attachable clothing and body parts
   - Eye/hair/skin color overlay system
   - Physical ragdolls
   - CC0-licensed base assets from MakeHuman

   ### Usage Workflow
   1. **Character Creation:** Use the Authoring Scene to generate base characters
   2. **Asset Import:** Place MakeHuman assets in `assets/clothes/` or `assets/body_parts/`
   3. **Equipment Attachment:** Use `asset_import` node to import and attach clothing
   4. **Rigging:** Follow Rigging Equipment guide for bone attachment
   5. **Animation:** Import Mixamo animations using the retargeting system

   ### Code Integration
   ```gdscript
   # Loading a Humanizer character programmatically
   var humanizer_character = preload("res://addons/humanizer/scenes/character3d.tscn").instantiate()
   add_child(humanizer_character)

   # Accessing shape key controls
   # (Specific API documentation lacking - need to examine source)
   ```

   **Recommended Companion:** Jolt Engine for Godot for improved physics

   **Insufficient Information:**
   - v3 API and migration path unclear
   - Limited programmatic usage examples
   - Animation retargeting technical details sparse
   - Performance characteristics undocumented

   ---

   ## 3. KayKit Character Pack (Adventurers)
   **Source:** https://kaylousberg.itch.io/kaykit-adventurers
   **Maintainer:** Kay Lousberg
   **License:** CC0 (Public Domain)

   ### What It Is
   A low-poly character asset pack featuring 5 (+3 in EXTRA tier) fully rigged and animated adventurer characters with 25+ weapons and accessories.

   ### Contents
   **Free Tier (5 characters):**
   - Barbarian, Ranger, Mage, Rogue, Knight
   - Various weapons/shields/bows/staffs/wands
   - Single 1024×1024 gradient atlas texture
   - FBX and GLTF formats

   **EXTRA Tier ($7.95+):** 3 additional characters (Engineer, Druid, larger Barbarian) + alternative textures

   **SOURCE Tier ($11.95+):** Blender source files (.blend)

   ### Technical Specifications
   - **Format:** FBX, GLTF (compatible with Unity, Godot, Unreal, Roblox)
   - **Texture:** Single 1024×1024 atlas (can be downsampled to 128×128 for mobile)
   - **Polycount:** Low-poly optimized
   - **Rigging:** Humanoid rig with basic movement animations
   - **Animation Compatibility:** Works with free KayKit Character Animations pack

   ### Installation
   1. Download from itch.io (name your own price)
   2. Extract to project assets directory
   3. Import GLTF files through Godot's import system
   4. Configure materials and animations as needed

   ### Usage in Godot
   ```gdscript
   # Basic character instantiation
   var adventurer_scene = preload("res://assets/kaykit/adventurers/barbarian.gltf")
   var character = adventurer_scene.instantiate()
   add_child(character)

   # Accessing animations
   var animation_player = character.get_node("AnimationPlayer")
   animation_player.play("run")

   # Equipment attachment
   # Accessories are separate mesh files that can be parented to bone attachments
   ```

   ### Integration Notes
   - Characters use a single gradient-based texture atlas
   - Materials are PBR-ready but may need adjustment for Godot's lighting
   - Animations are basic; consider KayKit Character Animations pack for more variety
   - CC0 license allows unrestricted commercial use (no attribution required)

   **Insufficient Information:**
   - Specific bone naming conventions not documented
   - No Godot-specific import settings provided
   - Animation state machine examples lacking

   ---

   ## 4. HTerrain (Heightmap Terrain Plugin)
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

   **Insufficient Information:**
   - Scripting API documentation incomplete
   - Multi-threading capabilities unclear
   - Maximum terrain size limitations not specified
   - VRAM usage patterns undocumented

   ---

   ## 5. AmbientCG & Polyhaven
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

   **Insufficient Information:**
   - No Godot-specific import optimization guides
   - Texture channel packing conventions vary
   - Model polygon counts and rigging quality inconsistent

   ---

   ## 6. NavigationRegion3D & NavigationMesh (Built-in Godot)
   **Documentation:** https://docs.godotengine.org/en/stable/classes/class_navigationregion3d.html

   ### What It Is
   Godot's built-in 3D navigation system for AI pathfinding, consisting of:
   - `NavigationRegion3D`: Defines navigable areas
   - `NavigationMesh`: Geometry defining walkable surfaces
   - `NavigationAgent3D`: AI controller for path following
   - `NavigationServer3D`: Backend server managing all navigation data

   ### How It Works
   1. **Baking:** Convert scene geometry into navigation mesh (convex polygon soup)
   2. **Querying:** AI agents request paths between points on the navmesh
   3. **Steering:** Agents follow paths with obstacle avoidance
   4. **Dynamic Updates:** Navmesh can be updated at runtime for destructible environments

   ### Installation
   Built into Godot 4.x – no installation required.

   ### Basic Setup
   ```gdscript
   # 1. Create NavigationRegion3D node
   # 2. Add NavigationMesh resource
   # 3. Bake navmesh from scene geometry
   # 4. Add NavigationAgent3D to AI characters

   # Programmatic baking example
   var nav_region = $NavigationRegion3D
   var nav_mesh = NavigationMesh.new()
   nav_mesh.cell_size = 0.2
   nav_mesh.cell_height = 0.2
   nav_mesh.agent_radius = 0.5
   nav_mesh.agent_height = 2.0
   nav_mesh.agent_max_climb = 0.8
   nav_mesh.agent_max_slope = 45.0

   nav_region.navigation_mesh = nav_mesh
   nav_region.bake_navigation_mesh()

   # AI agent usage
   var agent = NavigationAgent3D.new()
   agent.target_desired_distance = 0.5
   agent.path_desired_distance = 0.5
   agent.target_position = target_position

   func _physics_process(delta):
       if agent.is_navigation_finished():
           return

       var next_path_position = agent.get_next_path_position()
       var direction = global_position.direction_to(next_path_position)
       velocity = direction * speed
       move_and_slide()
   ```

   ### Advanced Features
   - **Navigation Layers:** Separate navmeshes for different agent types
   - **Navigation Links:** Jump pads, ladders, teleports
   - **Obstacle Avoidance:** Dynamic obstacle avoidance using RVO
   - **Crowd Simulation:** Groups of agents with collective avoidance
   - **Performance:** Multi-threaded pathfinding queries

   ### Best Practices
   1. Use primitive colliders (box, sphere, capsule) for dynamic objects
   2. Bake static geometry once, update dynamically for moving platforms
   3. Use navigation layers to separate ground/flying/water units
   4. Implement path smoothing for natural movement
   5. Cache path queries for frequently used routes

   **Insufficient Information:**
   - Performance scaling with large navmeshes (>100k polygons)
   - Multi-threading limitations on different platforms
   - Advanced dynamic obstacle avoidance tuning

   ---

   ## 7. Godot Steering AI Framework
   **Documentation:** https://gdquest.gitbook.io/godot-3-steering-ai-framework-reference
   **Repository:** Likely https://github.com/GDQuest/godot-steering-ai-framework
   **Maintainer:** GDQuest
   **Version:** Godot 3.x (3+ years outdated)
   **License:** MIT (assumed)

   ### What It Is
   A steering behavior framework inspired by GDX-AI, providing modular AI movement behaviors separate from Godot's built-in navigation system.

   ### Architecture
   - **GSAISteeringAgent:** Base agent class storing position, orientation, velocity
   - **GSAISteeringBehavior:** Individual behaviors (seek, flee, pursue, wander, etc.)
   - **GSAIBlend:** Behavior blending with weights
   - **GSAIPriority:** Behavior prioritization (first non-zero acceleration wins)
   - **GSAIProximity:** Neighborhood detection for group behaviors

   ### Installation
   1. Download from GitHub releases
   2. Copy `addons/com.gdquest.godot-steering-ai-framework` to project
   3. Place in organized directory (e.g., `res://src/libraries/`)
   4. Godot auto-registers all `GSAI*` classes

   ### Core Behaviors
   - **Seek/Flee:** Move toward/away from target
   - **Pursue/Evade:** Predictive chasing/escaping
   - **Arrive:** Decelerate to stop at target
   - **Wander:** Random exploration
   - **FollowPath:** Waypoint following
   - **AvoidCollisions:** Obstacle avoidance
   - **Flock:** Group behaviors (separation, alignment, cohesion)

   ### Complete Example (from documentation)
   ```gdscript
   extends KinematicBody2D

   export var speed_max := 450.0
   export var acceleration_max := 50.0
   export var angular_speed_max := 240
   export var angular_acceleration_max := 40
   export var health_max := 100
   export var flee_health_threshold := 20

   var velocity := Vector2.ZERO
   var angular_velocity := 0.0
   var linear_drag := 0.1
   var angular_drag := 0.1
   var acceleration := GSAITargetAcceleration.new()

   onready var current_health := health_max
   onready var agent := GSAISteeringAgent.new()
   onready var player: Node = get_tree().get_nodes_in_group("Player")[0]
   onready var player_agent: GSAISteeringAgent = player.agent
   onready var proximity := GSAIRadiusProximity.new(agent, [player_agent], 100)
   onready var flee_blend := GSAIBlend.new(agent)
   onready var pursue_blend := GSAIBlend.new(agent)
   onready var priority := GSAIPriority.new(agent)

   func _ready() -> void:
       # Agent configuration
       agent.linear_speed_max = speed_max
       agent.linear_acceleration_max = acceleration_max
       agent.angular_speed_max = deg2rad(angular_speed_max)
       agent.angular_acceleration_max = deg2rad(angular_acceleration_max)
       agent.bounding_radius = calculate_radius($CollisionPolygon2D.polygon)
       update_agent()

       # Behavior setup
       var pursue := GSAIPursue.new(agent, player_agent)
       pursue.predict_time_max = 1.5

       var flee := GSAIFlee.new(agent, player_agent)
       var avoid := GSAIAvoidCollisions.new(agent, proximity)
       var face := GSAIFace.new(agent, player_agent)
       face.alignment_tolerance = deg2rad(5)
       face.deceleration_radius = deg2rad(60)

       var look := GSAILookWhereYouGo.new(agent)
       look.alignment_tolerance = deg2rad(5)
       look.deceleration_radius = deg2rad(60)

       flee_blend.is_enabled = false
       flee_blend.add(look, 1)
       flee_blend.add(flee, 1)

       pursue_blend.add(face, 1)
       pursue_blend.add(pursue, 1)

       priority.add(avoid)
       priority.add(flee_blend)
       priority.add(pursue_blend)

   func _physics_process(delta: float) -> void:
       update_agent()

       if current_health <= flee_health_threshold:
           pursue_blend.is_enabled = false
           flee_blend.is_enabled = true

       priority.calculate_steering(acceleration)

       velocity = (velocity + Vector2(acceleration.linear.x, acceleration.linear.y) * delta).clamped(agent.linear_speed_max)
       velocity = velocity.linear_interpolate(Vector2.ZERO, linear_drag)
       velocity = move_and_slide(velocity)

       angular_velocity = clamp(angular_velocity + acceleration.angular * delta, -agent.angular_speed_max, agent.angular_speed_max)
       angular_velocity = lerp(angular_velocity, 0, angular_drag)
       rotation += angular_velocity * delta

   func update_agent() -> void:
       agent.position.x = global_position.x
       agent.position.y = global_position.y
       agent.orientation = rotation
       agent.linear_velocity.x = velocity.x
       agent.linear_velocity.y = velocity.y
       agent.angular_velocity = angular_velocity

   func calculate_radius(polygon: PoolVector2Array) -> float:
       var furthest_point := Vector2(-INF, -INF)
       for p in polygon:
           if abs(p.x) > furthest_point.x:
               furthest_point.x = p.x
           if abs(p.y) > furthest_point.y:
               furthest_point.y = p.y
       return furthest_point.length()

   func damage(amount: int) -> void:
       current_health -= amount
       if current_health <= 0:
           queue_free()
   ```

   ### Integration with Godot Navigation
   Steering behaviors can complement Godot's navigation system:
   - Use NavigationAgent3D for global pathfinding
   - Use GSAI for local obstacle avoidance and flocking
   - Blend behaviors for natural movement

   **Insufficient Information:**
   - Godot 4.x compatibility uncertain
   - No recent updates (3+ years)
   - 3D steering behaviors documentation minimal
   - Performance characteristics undocumented

   ---

   ## 8. Godot RTS Camera & Selection
   **Reference Implementation:** https://github.com/carmel4a/RTS-Camera2D
   **3D Alternative:** https://github.com/IndieQuest/GodotRtsCameraController3D
   **License:** MIT (assumed)

   ### What It Is
   A collection of camera controllers and selection systems for real-time strategy games, providing:
   - Edge-scrolling camera movement
   - Mouse drag panning
   - Zoom controls
   - Unit selection (rectangle/marquee selection)
   - Group control management

   ### 2D Camera (RTS-Camera2D)
   **Features:**
   - Keyboard (arrow keys) and mouse (edge, drag) controls
   - Configurable camera speed and margins
   - Zoom in/out with limits
   - Current camera property for multiple cameras

   **Installation:**
   1. Download from Asset Library or GitHub
   2. Extract `addons` folder to project
   3. Enable plugin in Project Settings → Plugins

   **Usage:**
   ```gdscript
   # Add RTS-Camera2D node to scene
   # Set Current property to true
   # Configure input actions:
   # - ui_up, ui_down, ui_left, ui_right
   # - camera_drag (right mouse button)
   # - camera_zoom_in, camera_zoom_out

   # Properties:
   # Key: Enable keyboard controls
   # Drag: Enable mouse drag (right button)
   # Edge: Enable edge scrolling
   # Wheel: Enable zoom wheel
   # Zoom Out Limit: Maximum zoom distance
   # Camera Speed: Movement speed
   # Camera Margin: Edge sensitivity (pixels)
   ```

   ### 3D Camera (GodotRtsCameraController3D)
   **Features:**
   - 3D RTS-style camera with tilt
   - Keyboard and mouse controls
   - Zoom with angle adjustment
   - Configurable movement bounds

   **Installation:** Copy `RtsCameraController.tscn` and `RtsCameraController.gd` to project

   **Required Input Actions:**
   - `camera_forward`, `camera_backward`
   - `camera_right`, `camera_left`
   - `camera_zoom_in`, `camera_zoom_out`
   - `camera_pan`, `camera_rotate`

   ### Selection System Patterns
   ```gdscript
   # Basic rectangle selection
   var selection_rect = RectangleShape2D.new()
   var selected_units = []

   func _input(event):
       if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
           if event.pressed:
               selection_start = event.position
               selecting = true
           else:
               selecting = false
               select_units_in_rect(selection_start, event.position)

       if selecting and event is InputEventMouseMotion:
           selection_end = event.position
           update_selection_visual()

   func select_units_in_rect(start: Vector2, end: Vector2):
       var rect = Rect2(start, end - start)
       selected_units.clear()

       for unit in get_tree().get_nodes_in_group("selectable_units"):
           if rect.has_point(unit.global_position):
               selected_units.append(unit)
               unit.set_selected(true)
   ```

   ### Advanced Features
   - **Multi-selection:** Shift+click to add/remove from selection
   - **Group Hotkeys:** Ctrl+1-9 to assign groups, 1-9 to recall
   - **Formation Movement:** Maintain formation when moving group
   - **Camera Bookmarks:** Save/restore camera positions
   - **Minimap Integration:** Click minimap to move camera

   ### Integration with Input System
   ```gdscript
   # Use Godot's InputMap for configurable controls
   InputMap.add_action("camera_drag")
   InputMap.action_add_event("camera_drag", InputEventMouseButton.new())
   # Configure in Project Settings for player customization
   ```

   **Insufficient Information:**
   - No standardized 3D RTS camera plugin
   - Selection system needs custom implementation
   - Formation movement algorithms not provided
   - Performance with large unit counts undocumented

   ---

   ## 9. Beehave (Behavior Trees)
   **Repository:** https://github.com/bitbrain/beehave
   **Documentation:** https://github.com/bitbrain/beehave/wiki
   **Maintainer:** bitbrain
   **Version:** 2.x (Godot 4.x), 1.x (Godot 3.x)
   **License:** MIT (assumed)

   ### What It Is
   A node-based behavior tree implementation for Godot, allowing visual AI behavior design within the scene tree with dedicated debugging tools.

   ### Architecture
   - **Behavior Tree Root:** `BeehaveTree` node managing tree execution
   - **Composite Nodes:** Sequence, Selector, Parallel, Random
   - **Decorator Nodes:** Inverter, Succeeder, Repeater, UntilFail
   - **Action Nodes:** Custom GDScript actions
   - **Condition Nodes:** Boolean checks for transitions
   - **Blackboard:** Shared memory for behavior tree nodes

   ### Installation
   1. Download latest release for your Godot version:
      - Godot 4.x → beehave 2.x branch
      - Godot 3.x → beehave 1.x branch
   2. Unpack `addons/beehave` folder to project
   3. Enable plugin in Project Settings → Plugins
   4. Copy `script_templates` to project root (optional)

   ### Version Compatibility
   | Godot Version | Beehave Branch | Beehave Version |
   |---------------|----------------|-----------------|
   | 3.x           | 3.x            | 1.x             |
   | 4.x           | 4.x            | 2.x             |
   | 4.5+          | 4.x            | 2.10+           |
   | 4.1.x         | 4.x            | 2.9.x           |
   | 4.0.x         | 4.x            | 2.7.x           |

   ### Basic Behavior Tree
   ```gdscript
   # Example: Enemy AI behavior tree
   # Tree structure:
   # - Selector (try in order):
   #   - Sequence (Attack if in range):
   #     - Condition: IsTargetInRange
   #     - Action: AttackTarget
   #   - Sequence (Chase target):
   #     - Condition: HasTarget
   #     - Action: MoveToTarget
   #   - Action: WanderIdle

   extends BeehaveTree

   func _ready():
       # Create tree nodes programmatically
       var root = Selector.new()
       add_child(root)

       var attack_sequence = Sequence.new()
       root.add_child(attack_sequence)

       var range_condition = Condition.new()
       range_condition.script = preload("res://scripts/conditions/is_target_in_range.gd")
       attack_sequence.add_child(range_condition)

       var attack_action = Action.new()
       attack_action.script = preload("res://scripts/actions/attack_target.gd")
       attack_sequence.add_child(attack_action)

       # ... additional branches
   ```

   ### Visual Editor Integration
   1. Add `BeehaveTree` node to scene
   2. Add behavior nodes as children
   3. Connect nodes in editor (parent-child relationships)
   4. Assign custom scripts to Action/Condition nodes
   5. Use Debug view to monitor tree execution

   ### Custom Action Implementation
   ```gdscript
   # res://scripts/actions/move_to_target.gd
   extends "res://addons/beehave/actions/Action.gd"

   class_name MoveToTargetAction

   @export var speed: float = 100.0
   @export var arrival_distance: float = 10.0

   func action_tick(actor: Node, blackboard: Blackboard) -> int:
       var target = blackboard.get_value("target")
       if not target:
           return FAILURE

       var direction = (target.global_position - actor.global_position).normalized()
       actor.velocity = direction * speed
       actor.move_and_slide()

       if actor.global_position.distance_to(target.global_position) <= arrival_distance:
           return SUCCESS

       return RUNNING
   ```

   ### Blackboard Usage
   ```gdscript
   # Setting blackboard values
   blackboard.set_value("target", player)
   blackboard.set_value("last_known_position", player.global_position)
   blackboard.set_value("health", current_health)

   # Reading in conditions/actions
   var target = blackboard.get_value("target")
   var health = blackboard.get_value("health", 100)
   ```

   ### Debugging Features
   - **Runtime Debug View:** Monitor active nodes in editor
   - **Performance Monitoring:** Track tree execution time
   - **Visual Status Indicators:** Color-coded node states
   - **Breakpoints:** Pause tree execution for inspection

   ### Integration Patterns
   - **State Machines:** Use behavior trees for AI decision making
   - **Animation Control:** Connect behavior states to animation tree
   - **Sensor Systems:** Update blackboard with perception data
   - **Utility AI:** Combine with scoring systems for complex decisions

   **Insufficient Information:**
   - Performance with deep/complex trees undocumented
   - Multi-agent coordination patterns not covered
   - Integration with Godot 4.x AnimationTree lacking examples
   - Blackboard serialization for save games not addressed

   ---

   ## Research Gaps & Next Steps

   ### Critical Information Missing
   1. **3D Controls Toolkit:** No API documentation, licensing unclear, Godot 4.6 compatibility unknown
   2. **Humanizer:** v3 architecture details sparse, programmatic API undocumented
   3. **HTerrain:** Advanced scripting API incomplete, performance characteristics unquantified
   4. **Godot Steering AI:** No Godot 4.x support, 3D behaviors undocumented
   5. **RTS Camera:** No standardized 3D solution, selection system needs custom implementation

   ### Recommended Further Investigation
   1. **Test each plugin** in Godot 4.6 to verify compatibility
   2. **Create example projects** for each plugin integration
   3. **Benchmark performance** with typical feudal game scenarios
   4. **Document migration paths** from Godot 3.x to 4.x for older plugins
   5. **Explore alternative plugins** where information is insufficient

   ### Skill Development Priorities
   1. **3D Controls Toolkit:** Basic character controller integration
   2. **Humanizer:** Character generation and animation retargeting
   3. **HTerrain:** Terrain sculpting and texture painting workflows
   4. **Beehave:** Behavior tree design for NPC AI
   5. **Navigation:** Advanced pathfinding with steering behaviors

   ### Risk Assessment
   - **High Risk:** Godot Steering AI (outdated), Humanizer v3 (unreleased)
   - **Medium Risk:** 3D Controls Toolkit (limited docs), RTS Camera (custom implementation needed)
   - **Low Risk:** HTerrain (well-documented), Beehave (active development), Asset libraries (proven)