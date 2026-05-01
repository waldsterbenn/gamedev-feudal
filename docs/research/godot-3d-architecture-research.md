# Godot 3D Project Architecture - Deep Research

**Date**: 2025-04-30  
**Source**: godotengine/godot-demo-projects (3d/), godot-gdscript skill, godot-project-init skill  
**Scope**: Architecture patterns for 3D games in Godot 4.x

---

## Executive Summary

After analyzing the official Godot demo projects and established best practices, this research identifies **5 core architectural pillars** for 3D Godot projects:

1. **Scene Composition** - Node hierarchies and instancing patterns
2. **Script Architecture** - State machines, components, signal-based decoupling
3. **Project Structure** - File organization and asset pipelines
4. **Performance Patterns** - Object pooling, caching, physics optimization
5. **Configuration Management** - project.godot, input maps, autoloads

---

## 1. Project Structure Standards

### 1.1 Recommended Folder Hierarchy

Based on demo projects analysis and `godot-project-init` skill:

```
project-name/
├── project.godot
├── icon.svg
├── .gitignore
├── scenes/
│   ├── player/
│   │   ├── player.tscn
│   │   ├── player.gd
│   │   └── components/         # Optional: decomposed components
│   ├── enemies/
│   │   ├── mob.tscn
│   │   ├── mob.gd
│   │   └── states/            # State machine states
│   ├── levels/
│   │   ├── level1.tscn
│   │   └── level1.gd
│   ├── ui/
│   │   ├── hud.tscn
│   │   └── menus/
│   └── props/                 # Reusable scene components
├── scripts/                    # Autoloads and shared scripts
│   ├── autoloads/
│   │   ├── EventBus.gd
│   │   ├── GameManager.gd
│   │   └── AudioManager.gd
│   └── resources/             # .tres resource definitions
│       ├── CharacterStats.tres
│       └── WeaponData.tres
├── assets/
│   ├── models/                # .glb/.gltf/.fbx files
│   ├── textures/              # .png/.webp/.jpg
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/
│   ├── fonts/
│   └── materials/            # .tres material files
└── addons/                    # Editor plugins (commit these!)
```

**Key Rules from Demo Projects:**
- **Engine-agnostic naming**: `feudal-age/` NOT `feudal-age-godot/`
- **Single root .gitignore**: No nested .gitignore files
- **Commit .import files**: These define asset processing (demo projects all commit them)
- **Never commit `.godot/` cache**: This is local editor state only

### 1.2 .gitignore Template

```gitignore
# Godot 4.x - local editor cache
.godot/

# Godot 4.x - local editor state
.editor_layout.cfg*
.editor_node_info.cfg*

# OS files
.DS_Store
Thumbs.db

# IDE files
.vscode/
.idea/
*.swp
*.swo
```

**Critical**: Do NOT ignore `*.import` files - they're project data, not cache!

---

## 2. Scene Architecture Patterns

### 2.1 Scene Composition Principles

From `squash_the_creeps` and `platformer` demos:

**Rule 1: One Scene = One Responsibility**
```
Player.tscn
├── CharacterBody3D (root - handles physics)
│   ├── MeshInstance3D (visuals)
│   ├── CollisionShape3D (physics)
│   ├── AnimationPlayer (animation)
│   ├── Camera3D (optional: first-person)
│   └── Area3D (hitboxes/detectors)
```

**Rule 2: Use Node3D as Organizational Root for Pure Logic Scenes**
```
Main.tscn (Node3D root - doesn't participate in physics)
├── WorldEnvironment
├── DirectionalLight3D
├── Player (instanced)
├── Mobs (container)
│   └── Mob (instanced multiples)
└── UI (CanvasLayer)
```

### 2.2 TSCN Format Requirements (Godot 4.x)

From `godot-gdscript` skill - **MANDATORY** for all scene files:

```gdscript
[gd_scene load_steps=4 format=3 uid="uid://abc123"]

[ext_resource type="Script" path="res://scripts/player.gd" id="1"]
[ext_resource type="PackedScene" path="res://assets/meshes/character.glb" id="2"]

[sub_resource type="CapsuleShape3D" id="1"]
radius = 0.5
height = 2.0

[node name="Player" type="CharacterBody3D"]
script = ExtResource("1")

[node name="CollisionShape3D" type="CollisionShape3D" parent="."]
shape = SubResource("1")
```

**Critical Rules:**
- `format=3` is MANDATORY (Godot 4 only)
- `load_steps` = 1 (root) + count of ext_resource + sub_resource
- Use `parent="."` for direct children of root
- Never include root name in parent paths

### 2.3 Instancing Pattern

From `squash_the_creeps/Main.tscn`:
```gdscript
[node name="Mob" parent="." instance=ExtResource("3")]
# You can override properties:
position = Vector3(0, 0, 0)
```

**Best Practice**: Use `@export` to pass dependencies:
```gdscript
# Main.gd
@export var mob_scene: PackedScene

func spawn_mob():
    var mob = mob_scene.instantiate()
    add_child(mob)
    # Pass data via method call, not direct property access
    mob.initialize(spawn_pos, target_pos)
```

---

## 3. Script Architecture Patterns

### 3.1 State Machine Pattern

From `godot-gdscript` skill and `platformer` demo:

**Structure:**
```
player.tscn
├── CharacterBody3D (root)
│   └── StateMachine (Node)
│       ├── IdleState (Node)
│       ├── WalkState (Node)
│       ├── JumpState (Node)
│       └── AttackState (Node)
```

**StateMachine.gd:**
```gdscript
class_name StateMachine extends Node

@export var initial_state: State
var current_state: State
var states: Dictionary = {}

func _ready() -> void:
    for child in get_children():
        if child is State:
            states[child.name] = child
            child.state_machine = self
            child.process_mode = Node.PROCESS_MODE_DISABLED
    
    if initial_state:
        transition_to(initial_state.name)

func transition_to(state_name: StringName, msg: Dictionary = {}) -> void:
    if current_state:
        current_state.exit()
        current_state.process_mode = Node.PROCESS_MODE_DISABLED
    
    current_state = states[state_name]
    current_state.process_mode = Node.PROCESS_MODE_INHERIT
    current_state.enter(msg)
```

**Individual State.gd:**
```gdscript
class_name State extends Node

var state_machine: StateMachine
var actor: CharacterBody3D  # The parent's parent

func _ready() -> void:
    actor = get_parent().get_parent() as CharacterBody3D

func enter(_msg := {}) -> void:
    pass

func exit() -> void:
    pass

func _physics_process(_delta: float) -> void:
    pass
```

### 3.2 Component Pattern

From `godot-gdscript` skill (HealthComponent example):

```gdscript
# health_component.gd
class_name HealthComponent extends Node

signal died
signal health_changed(new_health: int)

@export var max_health: int = 100
var current_health: int

func _ready() -> void:
    current_health = max_health

func take_damage(amount: int) -> void:
    current_health -= amount
    health_changed.emit(current_health)
    if current_health <= 0:
        died.emit()

# Usage in Player.gd:
# @onready var health: HealthComponent = $HealthComponent
# health.died.connect(_on_died)
```

### 3.3 EventBus (Global Singleton) Pattern

From `godot-gdscript` skill:

**EventBus.gd (Autoload):**
```gdscript
class_name EventBus extends Node

# Game events
signal player_died
signal score_changed(new_score: int)
signal gold_changed(amount: int)

# Audio events
signal music_changed(track: AudioStream)
signal sfx_played(sound: AudioStream, position: Vector3)
```

**Usage:**
```gdscript
# In any script:
EventBus.score_changed.emit(100)

# Listening:
EventBus.score_changed.connect(_on_score_changed)
```

### 3.4 Resource-Based Data Pattern

From `godot-gdscript` skill:

**CharacterStats.tres:**
```ini
[gd_resource type="Resource" script_class="CharacterStats"]

[resource]
max_health = 100
move_speed = 5.0
jump_impulse = 15.0
```

**CharacterStats.gd:**
```gdscript
class_name CharacterStats extends Resource

@export var max_health: int = 100
@export var move_speed: float = 5.0
@export var jump_impulse: float = 15.0
```

**Usage:**
```gdscript
@export var base_stats: CharacterStats
var stats: CharacterStats

func _ready() -> void:
    # Duplicate to avoid modifying .tres file
    stats = base_stats.duplicate()
```

---

## 4. Physics & Collision Architecture

### 4.1 Collision Layer Naming

From `squash_the_creeps/project.godot`:
```ini
[layer_names]

3d_physics/layer_1="player"
3d_physics/layer_2="enemies"
3d_physics/layer_3="world"
3d_physics/layer_4="pickups"
3d_physics/layer_5="projectiles"
```

### 4.2 Physics Settings

From demo projects (`squash_the_creeps`, `truck_town`):
```ini
[physics]

common/physics_ticks_per_second=120
3d/physics_engine="Jolt Physics"  # or "GodotPhysics"
common/physics_interpolation=true  # Smooths physics at high frame rates
```

**Recommendation**: Use Jolt Physics for better 3D physics simulation.

### 4.3 CharacterBody3D Pattern

From `squash_the_creeps/Player.gd`:
```gdscript
extends CharacterBody3D

@export var speed: float = 14.0
@export var jump_impulse: float = 20.0
@export var fall_acceleration: float = 75.0

func _physics_process(delta: float) -> void:
    var direction := Vector3.ZERO
    
    # Input handling
    if Input.is_action_pressed(&"move_right"):
        direction.x += 1
    # ... etc
    
    if direction != Vector3.ZERO:
        direction = direction.normalized()
        basis = Basis.looking_at(direction)
    
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed
    
    # Gravity
    velocity.y -= fall_acceleration * delta
    
    # Jumping
    if is_on_floor() and Input.is_action_just_pressed(&"jump"):
        velocity.y += jump_impulse
    
    move_and_slide()
    
    # Collision handling
    for i in range(get_slide_collision_count()):
        var collision := get_slide_collision(i)
        if collision.get_collider().is_in_group(&"mob"):
            # Handle collision
            pass
```

---

## 5. Navigation & AI Patterns

### 5.1 NavigationAgent3D Pattern

From `navigation/character.gd`:
```gdscript
extends Marker3D  # or CharacterBody3D

@export var character_speed := 10.0

@onready var _nav_agent := $NavigationAgent3D as NavigationAgent3D

func _physics_process(delta: float) -> void:
    if _nav_agent.is_navigation_finished():
        return
    
    var next_position := _nav_agent.get_next_path_position()
    var offset := next_position - global_position
    global_position = global_position.move_toward(next_position, delta * character_speed)
    
    # Face movement direction
    offset.y = 0
    if not offset.is_zero_approx():
        look_at(global_position + offset, Vector3.UP)

func set_target_position(target: Vector3) -> void:
    _nav_agent.target_position = target
```

### 5.2 NavigationServer3D Direct API

From `navigation/navmesh.gd`:
```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        var camera := $Camera3D as Camera3D
        var from := camera.project_ray_origin(event.position)
        var to := from + camera.project_ray_normal(event.position) * 1000.0
        
        # Get closest point on navmesh
        var nav_map := get_world_3d().navigation_map
        var target := NavigationServer3D.map_get_closest_point_to_segment(
            nav_map, from, to
        )
        
        _robot.set_target_position(target)
```

---

## 6. Input Handling

### 6.1 Input Map Configuration

From demo projects:
```ini
[input]

move_left={
"deadzone": 0.2,
"events": [Object(InputEventKey,"keycode":0,"physical_keycode":65,"unicode":113)]
}
move_right={
"deadzone": 0.2,
"events": [Object(InputEventKey,"keycode":0,"physical_keycode":68,"unicode":100)]
}
jump={
"deadzone": 0.2,
"events": [Object(InputEventKey,"keycode":32)]
}
```

**Best Practice**: Use `&"action_name"` string names (faster than String):
```gdscript
if Input.is_action_pressed(&"move_left"):
    direction.x -= 1
```

### 6.2 Input Vector Helper

From `platformer/player.gd`:
```gdscript
var movement_vec2 := Input.get_vector(
    &"move_left", &"move_right", 
    &"move_forward", &"move_back"
)
var movement_direction := cam_basis * Vector3(movement_vec2.x, 0, movement_vec2.y)
```

---

## 7. Animation Patterns

### 7.1 AnimationPlayer + Script

From `squash_the_creeps`:
```gdscript
@onready var _animation_player := $AnimationPlayer as AnimationPlayer

func _physics_process(_delta: float) -> void:
    if direction != Vector3.ZERO:
        _animation_player.speed_scale = 4  # Run animation faster
    else:
        _animation_player.speed_scale = 1
```

### 7.2 AnimationTree for Complex Blending

From `platformer/player.gd`:
```gdscript
@onready var _animation_tree := $AnimationTree as AnimationTree

func _physics_process(delta: float) -> void:
    # Blend between idle/walk based on speed
    _animation_tree[&"parameters/run/blend_amount"] = horizontal_speed / MAX_SPEED
    
    # Blend between walk/run based on speed threshold
    _animation_tree[&"parameters/speed/blend_amount"] = clamp(
        horizontal_speed / (MAX_SPEED * 0.5), 0, 1
    )
    
    # State blend (floor/air)
    _animation_tree[&"parameters/state/blend_amount"] = anim
```

---

## 8. Performance Optimization

### 8.1 Object Pooling

From `godot-gdscript` skill:
```gdscript
# object_pool.gd
class_name ObjectPool extends Node

@export var pooled_scene: PackedScene
@export var initial_size: int = 10

var _available: Array[Node] = []
var _active: Array[Node] = []

func _ready() -> void:
    for i in initial_size:
        var instance = pooled_scene.instantiate()
        instance.process_mode = Node.PROCESS_MODE_DISABLED
        _available.append(instance)

func get_instance() -> Node:
    var instance: Node
    if _available.is_empty():
        instance = pooled_scene.instantiate()
    else:
        instance = _available.pop_back()
    
    instance.process_mode = Node.PROCESS_MODE_INHERIT
    _active.append(instance)
    return instance

func return_instance(instance: Node) -> void:
    instance.process_mode = Node.PROCESS_MODE_DISABLED
    _active.erase(instance)
    _available.append(instance)
```

### 8.2 Caching and Optimization

From `godot-gdscript` skill:

**DO:**
```gdscript
# Cache node references
@onready var sprite: Sprite3D = $Sprite3D
@onready var hitbox: Area3D = %Hitbox  # Unique name access

# Type everything
var speed: float = 200.0
var items: Array[Item] = []
```

**DON'T:**
```gdscript
# Don't use get_node() in _process()
func _process(_delta):
    $Sprite3D.visible = false  # BAD: string lookup every frame

# Don't ignore typing
var speed = 200  # BAD: variant type
```

---

## 9. Rendering Configuration

### 9.1 project.godot Rendering Settings

From `truck_town/project.godot`:
```ini
[rendering]

# Anti-aliasing
anti_aliasing/quality/msaa_3d=2  # 0=disabled, 2=4x MSAA

# Shadows
lights_and_shadows/directional_shadow/soft_shadow_filter_quality=3  # 0-3
lights_and_shadows/directional_shadow/size=8192

# Textures
textures/default_filters/anisotropic_filtering_level=4
textures/vram_compression/import_etc2_astc=true

# Performance
anti_aliasing/quality/use_debanding=true
```

### 9.2 Rendering Method Selection

From `godot-project-init` skill:
```ini
[rendering]

renderer/rendering_method="mobile"  # Options: forward_plus, mobile, gl_compatibility
```

- **forward_plus**: Desktop/console (best quality, VoxelGI, SDFGI)
- **mobile**: Mobile/lower-end PC (good quality, faster)
- **gl_compatibility**: Web/old hardware (lowest quality)

---

## 10. Autoload Architecture

### 10.1 When to Use Autoloads

From demo projects analysis:

**Good Candidates:**
- **EventBus**: Global event system
- **GameManager**: Game state, scene management
- **AudioManager**: Music/SFX playback
- **SaveManager**: Save/load system
- **SettingsManager**: User preferences

**Bad Candidates:**
- Player-specific logic (use composition)
- Level-specific logic (use scene scripts)
- Anything that should be instanced multiple times

### 10.2 Autoload Configuration

From `squash_the_creeps/project.godot`:
```ini
[autoload]

MusicPlayer="*res://MusicPlayer.tscn"  # * prefix = singleton
GameManager="*res://scripts/autoloads/GameManager.gd"
EventBus="*res://scripts/autoloads/EventBus.gd"
```

**Note**: Autoloads can be scenes (.tscn) or scripts (.gd). Scenes are useful for visual autoloads (like HUD).

---

## 11. Key Takeaways & Best Practices

### 11.1 Architecture Checklist

- [ ] **Composition over Inheritance**: Use components (HealthComponent, MovementController)
- [ ] **State Machines**: All transient behaviors use StateMachine pattern
- [ ] **EventBus**: Decoupled communication via signals
- [ ] **Resource Data**: Use .tres files for tuning, `duplicate()` at runtime
- [ ] **Object Pooling**: For frequent entities (projectiles, enemies)
- [ ] **Cache References**: `@onready` for all node lookups
- [ ] **Type Everything**: Static typing enables compiler optimizations
- [ ] **Collision Layers**: Named layers in project.godot
- [ ] **Signal Godot 4 Syntax**: `signal name(args)` and `signal_name.emit()`

### 11.2 Common Pitfalls (from Demo Analysis)

1. **Forgetting `format=3`** in .tscn files (Godot 4 requirement)
2. **Wrong `load_steps` count** (causes resource loading issues)
3. **Not using `@onready`** (expensive runtime lookups)
4. **Modifying .tres directly** (use `duplicate()`)
5. **Ignoring physics interpolation** (`common/physics_interpolation=true`)
6. **Committing `.godot/` folder** (should be in .gitignore)
7. **Not committing `*.import` files** (should be committed!)

### 11.3 Recommended Project Template

For new 3D projects, use `godot-project-init` skill or copy this structure:
```bash
mkdir -p scenes/{player,enemies,levels,ui,props}
mkdir -p scripts/{autoloads,resources}
mkdir -p assets/{models,textures,audio/{music,sfx},fonts,materials}
```

---

## 12. References

- **Godot Demo Projects**: https://github.com/godotengine/godot-demo-projects/tree/master/3d
- **godot-gdscript Skill**: `~/.hermes/profiles/gamedev/skills/gamedev/godot-gdscript/SKILL.md`
- **godot-project-init Skill**: `~/.hermes/profiles/gamedev/skills/gamedev/godot-project-init/SKILL.md`
- **Godot 4 Docs**: https://docs.godotengine.org/en/4.x/

---

**Research Complete** ✓
