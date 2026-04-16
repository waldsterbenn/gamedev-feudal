Re# Feudal Development Technical Instruction (v1.0)
## Project: gamedev-feudal

This document governs all development for the gamedev-feudal project. All agents and developers must adhere to these technical specifications and architectural mandates.

---


### 1. Plugins & Assets (Recommended Stack)
The following tools are recommended for high-quality project development. While these are currently our standard, teams may select alternative plugins for specific slice requirements, provided they are documented.

*   **3D Controls Toolkit**: Tools for enhanced camera manipulation and user interaction in 3D. [Skill Documentation](/docs/skills/3d-controls-toolkit/SKILL.md)
*   **Humanizer**: Plugin for procedural character animation and animation retargeting. [Skill Documentation](/docs/skills/humanizer/SKILL.md)
*   **KayKit Character Pack (Adventurers)**: Low-poly asset pack providing modular character models. (Note: This plugin is currently under evaluation)
*   **HTerrain**: High-performance heightmap terrain system with support for texture painting and foliage. [Skill Documentation](/docs/skills/hterrain/SKILL.md)
*   **AmbientCG / Polyhaven**: Primary sources for high-quality, PBR-ready 3D textures, models, and HDRI environments. [Skill Documentation](/docs/skills/ambientcg-polyhaven/SKILL.md)
*   **NavigationRegion3D & NavigationMesh**: Built-in Godot tools for generating, baking, and managing navigation meshes in 3D space. [Skill Documentation](/docs/skills/navigation-region3d/SKILL.md)
*   **Godot Steering AI**: Framework for implementing autonomous movement behaviors and flocking. [Skill Documentation](/docs/skills/godot-steering-ai/SKILL.md)
*   **Godot RTS Camera & Selection**: Set of tools/plugins for controlling cameras in top-down/RTS perspective and managing entity selection. [Skill Documentation](/docs/skills/rts-camera-selection/SKILL.md)
*   **Beehave**: Behavior Tree addon designed for visual, modular AI logic and decision-making. [Skill Documentation](/docs/skills/beehave-behavior-trees/SKILL.md)

**Skill-Based Development**: Each plugin has a corresponding skill file in `/docs/skills/` that provides installation, configuration, and usage patterns. These skills are also mirrored to the Hermes assistant profile for AI-assisted development. When implementing plugin features, consult the relevant skill first.

---

### 2. Deep Dive: GDScript & Architectural Patterns
For coding agents and developers, these patterns are mandatory for maintainability and performance.

#### A. The Component-Based Pattern
Stop writing "God" scripts (scenes > 500 lines). Every complex Node must be composed of smaller, single-responsibility scripts.
*   **Implementation**: Create separate nodes for specific behaviors (e.g., `HealthComponent.gd`, `HitboxComponent.gd`, `MovementController.gd`).
*   **Communication**: Use *Signals* for child-to-parent communication. The Component emits `health_depleted`; the parent interprets this and triggers the `Death` animation or state.

#### B. The State Machine Pattern (Standardized)
All transient entity behaviors (Player Movement, Enemy AI) must use State Machines.
*   **Structure**: 
    1.  `StateMachine` (Parent Node): Manages the active state and transitions.
    2.  `State` (Child Node): Each behavior is a standalone node inheriting from a `State` base class.
*   **Code Template**:
```gdscript
# StateMachine.gd (Autoloaded Controller)
var current_state: State
func change_state(new_state: State):
    current_state.exit()
    current_state = new_state
    current_state.enter()
```

#### C. Performance & Resource Management
Refuse to accept FPS loss in `_process`.
*   **Cached References**: Never use `get_node()` in `_process()`.
```gdscript
# CORRECT
@onready var sprite: Sprite2D = $Sprite2D
func _process(delta):
    sprite.rotate(1) # Fast

# INCORRECT
func _process(delta):
    get_node("Sprite2D").rotate(1) # Slow (string lookup every frame)
```
*   **Object Pooling**: For projectiles/enemies, implement this pattern:
    1.  `_ready()`: Initialize a `pool = []` of pre-instantiated nodes.
    2.  `spawn()`: Pop from pool, set `visible=true`, `process_mode=PROCESS_MODE_INHERIT`.
    3.  `kill()`: Set `visible=false`, `process_mode=PROCESS_MODE_DISABLED`, push back to array.


#### D. Input & Event Handling
*   **Input**: Do not hardcode keys. Use Godot's `Input Map` (Project Settings) and `Input.get_action_strength()` / `Input.get_axis()` for controller/keyboard abstraction. 
*   **EventBus Pattern**: For global events (e.g., `gold_amount_changed`), do not pass references between scenes. Create a dedicated `EventBus` singleton:
```gdscript
# EventBus.gd
signal gold_changed(new_amount: int)
# Usage:
EventBus.gold_changed.emit(100)
```

#### E. 3D-Specific Best Practices
Since this is a 3D game, optimized spatial management is critical.

*   **Node Hierarchy**: Always use `Node3D` as your base for spatial objects. Use `CharacterBody3D` for players and AI.
*   **Collision Optimization**:
    *   Avoid complex mesh colliders for dynamic objects. Use primitive shapes (Box, Sphere, Capsule) anchored to `CollisionShape3D` nodes for the physics engine.
    *   Use `CollisionLayer` and `CollisionMask` systematically (e.g., Layer 1: Environment, Layer 2: Player, Layer 3: Enemies) to avoid expensive collision checks.
*   **Spatial Pathfinding**:
    *   Bake navigation using a `NavigationRegion3D`.
    *   Utilize `NavigationAgent3D` for AI pathfinding; avoid manual coordinate manipulation unless creating basic steering behaviors.
*   **Rendering & Graphics**:
    *   **LOD (Level of Detail)**: Use `MeshInstance3D` features or `LODGroup` nodes for distant objects to maintain high FPS.
    *   **Visibility**: Use `VisibleOnScreenNotifier3D` to disable processing/animation for off-screen objects, significantly reducing CPU/GPU overhead.
*   **Coordinate System**: Godot uses Y-Up. Ensure imported models from Blender or other tools are exported to match this scale and orientation.




---

### 7. Engine Integration, MCP, and Debugging Workflow

To optimize iteration, we utilize the Godot MCP (Model Context Protocol) server for deep engine integration, alongside command-line tools for testing and logging.

#### A. Godot MCP Server Setup
The MCP server bridges the AI developer (or coding agent) directly to the Godot Editor/Project.
*   **Startup**: Ensure the Godot MCP server is running (`godot-mcp serve`).
*   **Connection**: Configure Hermes to use the Godot MCP server:
    `hermes mcp add godot --command godot-mcp --args serve`
*   **Verification**: Test connection with `hermes mcp test godot`.
*   **Capabilities**: The MCP server enables programmatic tasks including:
    *   Launching/closing the editor: `launch_editor`
    *   Running scenes: `run_project`
    *   Managing nodes/scenes: `add_node`, `create_scene`, `save_scene`
    *   Metadata lookup: `get_project_info`, `get_godot_version`

#### B. Running, Debugging, and Log Analysis
Effective iteration relies on rapid feedback loops via the terminal:

*   **Test and Run**:
    *   Execute the project: `hermes mcp call godot run_project '{"projectPath": "./src/feudal-age/"}'`
    *   Run specific scenes: Use the `scene` argument in `run_project`.
*   **Log & Debugging Output**:
    *   View console output/errors: `hermes mcp call godot get_debug_output`
    *   When an error occurs, coding agents must call `get_debug_output` to identify the stack trace.
*   **Automated Verification**:
    *   Before submitting changes, coding agents should attempt a "Headless Test Run":
        `godot --path ./src/feudal-age/ --headless --quit`
    *   If the exit code is non-zero, capture logs to `./build/error_log.txt` and fix before proceeding.
*   **Development Iteration Cycle**:
    1.  **Modify** script/scene (code or MCP tool).
    2.  **Validate** node existence/integrity via `hermes mcp call godot get_project_info`.
    3.  **Run** integration test via `hermes mcp`.
    4.  **Analyze** output through `get_debug_output`.
    5.  **Patch** issues immediately.

*   **Scene Organization**: Utilize "Editable Children" sparingly; prefer composition and signals to keep scenes decoupled.
*   **Resource Management**: Save balance/tuning data in `.tres` (Resource) files. This allows designers to balance the game without touching script code.
*   **UI Workflow**: For complex interfaces, build individual UI components as their own reusable scenes, then instance them into views.
*   **Object Pooling**: Do not use `queue_free()` for projectiles or frequently spawned enemies; push them to an `ObjectPool` manager and hide/reset them for reuse.
*   **Godot Profiler**: Frequently run the built-in Profiler while testing to catch resource spikes and frame-time dips before they become systemic.


---

### 3. Project Structure
Maintain the standardized following layout:

*   `scenes/`: All .tscn files (UI, Characters, Levels)
*   `scripts/`: Logic files (matches scene folder structure)
*   `resources/`: .tres data (NPC stats, Item data)
*   `assets/`: Imported external sources (Textures, Models)
*   `addons/`: Mandatory plugins
*   `shaders/`: Shader logic

---

### 4. Development Standards
*   **Naming Conventions**:
    *   Scenes/Nodes: PascalCase
    *   Scripts/Variables: snake_case
    *   Constants: UPPER_CASE
*   **Optimization**: 
    *   Cache persistent node references via `@onready`.
    *   Do not execute expensive operations (pathfinding, heavy math) in `_process()`. Utilize `_physics_process` or timers.
*   **Version Control**:
    *   Maintain a single root .gitignore covering cached directories (.godot/, .import/). 
    *   Do not create nested .gitignore files.


---

### 6. Development Workflow for Slices & Iteration
To iterate on new features, bug fixes, or experimental content without disrupting the main codebase, follow these rules for working with "vertical slices":

*   **Slice Directory**: All experimental or feature-specific work belongs in `src/slice_<feature_name>/`.
*   **Decoupling**: Slices should be self-contained in their functionality. Avoid hard-linking dependencies from the main `src/feudal-age/` source unless absolutely required. 
*   **Modifying project.godot**: If a slice introduces a new main scene or requires specific engine configurations, document these changes in the slice's own README. Avoid overriding the master `project.godot` file in the root directory.

*   **Asset Management (The Original Master Policy)**:
    *   **Keep a Master Source**: Never modify assets directly in the original download folder. Store all raw 3rd-party asset packs in a read-only `/assets/original/` directory.
    *   **Working Copy**: When an asset is required, copy the necessary files into `src/feudal-age/assets/`. Modify these copies to fit the game's requirements.
    *   **Reasoning**: This keeps the Godot project self-contained and version-controlled, while preserving the original source files in `/assets/original/` for easy referencing, diffing, or manual merging if the original author releases an update.

*   **UID Management**: When copying scenes from the main project into a slice, ensure all script and resource UIDs are updated to match the new local file paths to prevent "broken" file states.
*   **Merge Policy**: Once a feature in a slice is stable, migrate the tested modules, scenes, and scripts into `src/feudal-age/`. Delete the slice folder after migration.
*   **No Nested .git**: Ensure slices do not contain internal `.git` directories or submodules, as this breaks parent repo gitlink references.

*   **Core Systems**: Design must reflect the tension between "Demesne" (direct management) and "Vassal" (indirect management).
*   **Hierarchy Simulation**: Implement the "Three Estates" model (Those who pray, Those who fight, Those who work) as the logical basis for NPC behaviors and AI decision-making.
*   **Scalability**: UI design must provide clear grand-strategic visibility for high-level taxation/territory control, while retaining tactile interaction for localized tasks like building placement or unit management.