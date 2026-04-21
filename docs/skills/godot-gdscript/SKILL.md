---
name: godot-gdscript
description: Use this skill when working on any Godot 4.6 task — writing GDScript, creating or editing .tscn scene files, .tres resource files, or debugging scene load failures. Keywords: godot, gdscript, tscn, tres, scene, node, signal, CharacterBody2D, export, resource, instancing, state machine, component, object pool.
---

# Godot 4.6 — GDScript & Scene Authoring

## MANDATORY: Validate After Every File Write

After writing or editing any `.tscn`, `.tres`, or `.gd` file, run:

```
python ./scripts/validate_godot.py <path/to/file>
```

To validate the whole project at once:
```
python ./scripts/validate_godot.py --all
```

**Do not present the file to the user until validation passes with zero errors.**
If validation fails, fix all errors and re-run before continuing.

---

## TSCN Scene Files — Exact Format

### File header (always line 1)
```
[gd_scene load_steps=2 format=3 uid="uid://abc123"]
```
- `format=3` is mandatory — Godot 4 only
- `load_steps` = number of `ext_resource` + `sub_resource` entries + 1
- `uid` is optional, Godot adds it on first save — omit if unknown

### External resources
```
[ext_resource type="Script" path="res://scripts/player.gd" id="1"]
[ext_resource type="PackedScene" path="res://scenes/bullet.tscn" id="2"]
[ext_resource type="Texture2D" path="res://art/player.png" id="3"]
```
- `type` must be exact: `Script`, `PackedScene`, `Texture2D`, `AudioStream`, `FontFile`, etc.
- IDs must be unique strings — keep them simple: `"1"`, `"2"` etc.

### Internal sub-resources
```
[sub_resource type="CapsuleShape2D" id="CapsuleShape2D_1"]
radius = 16.0
height = 48.0
```

### Nodes
```
[node name="Player" type="CharacterBody2D"]
script = ExtResource("1")

[node name="Sprite2D" type="Sprite2D" parent="."]
texture = ExtResource("3")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("CapsuleShape2D_1")

[node name="Gun" type="Node2D" parent="."]

[node name="Muzzle" type="Marker2D" parent="Gun"]
```

### Node parenting rules — most common source of errors
- Root node: **no `parent=` key at all**
- Direct child of root: `parent="."`
- Grandchild of root: `parent="ChildName"`
- Great-grandchild: `parent="ChildName/GrandchildName"`
- **Never** include the root node's own name in any parent path

---

## GDScript — Strict Rules

### Type everything — no exceptions
```gdscript
# CORRECT
var speed: float = 200.0
var health: int = 100
var target: Node2D
var items: Array[Item] = []

func get_damage() -> int:
    return _damage

func move_to(pos: Vector2) -> void:
    global_position = pos

@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = %Hitbox
```

### Script section order
```gdscript
class_name PlayerController
extends CharacterBody2D

# 1. signals
# 2. enums
# 3. constants
# 4. exports (@export var name: type = value)
# 5. public vars
# 6. private vars (underscore prefix)
# 7. onready (@onready var name: type = value)
# 8. built-in callbacks (_ready, _process, _physics_process)
# 9. public functions
# 10. private functions (_die)
```

### Signals — Godot 4 Syntax Only
```gdscript
signal health_changed(new_health: int)
health_changed.emit(_health)
button.pressed.connect(_on_button_pressed)
```

---

## Advanced Architectural Patterns

### 1. State Machine
Decouple logic into discrete state nodes. Disable processing on inactive states.

```gdscript
# state_machine.gd
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

### 2. EventBus (Global Singleton)
Use a global `EventBus.gd` autoload for decoupled communication.

```gdscript
# EventBus.gd (Autoload)
extends Node
signal player_died
signal gold_changed(amount: int)
```

### 3. Resource-based Data
Use `.tres` files for configuration. Always duplicate resources for runtime modification.

```gdscript
@export var base_stats: CharacterStats
var stats: CharacterStats

func _ready() -> void:
    stats = base_stats.duplicate() # Avoid modifying the .tres file directly
```

### 4. Component System
Decompose complex nodes into single-responsibility components (e.g., `HealthComponent`, `MovementController`).

```gdscript
# health_component.gd
class_name HealthComponent extends Node
signal died
@export var max_health: int = 100
var current_health: int

func take_damage(amount: int) -> void:
    current_health -= amount
    if current_health <= 0:
        died.emit()
```

### 5. Object Pooling
Reuse frequently spawned objects (projectiles, enemies) to avoid GC hitches.

```gdscript
# object_pool.gd
var _available: Array[Node] = []
func get_instance() -> Node:
    if _available.is_empty():
        return pooled_scene.instantiate()
    return _available.pop_back()
```

---

## Performance & Best Practices

### Do's
- **Cache node references**: Use `@onready` for persistent lookups.
- **Type everything**: Static typing enables compiler optimizations.
- **Use signals**: Prefer signals for "downward" or cross-branch communication.
- **Object Pooling**: Essential for high-frequency entities.
- **Disable Processing**: Use `set_process(false)` for nodes off-screen or inactive.

### Don'ts
- **Don't use `get_node()` or `$` in `_process()`**: It's an expensive string lookup.
- **Don't put logic in Resources**: Resources should be data containers.
- **Don't use `free()`**: Always use `queue_free()` for safe removal.
- **Don't ignore Collision Layers**: Systematically use Layers and Masks for performance.

---

## Project Copying & Slice Workflow

When duplicating a Godot project (e.g., `cp -r slice1 slice2`), the `.godot/` folder **must be deleted** before the copy is opened or run. The `.godot/global_script_class_cache.cfg` caches absolute paths from the source project, causing class-resolution errors such as:

```
SCRIPT ERROR: Parse Error: Class "ThirdPersonControler3D" hides a global script class.
```

Fix:
```bash
rm -rf src/new-slice/.godot
```

Then run a headless import pass:
```bash
godot --path ./src/new-slice --editor --quit --headless
```

## 3D Asset Import (FBX) Pitfalls

### Texture path mismatches
FBX files often embed hard-coded texture filenames. If the copied texture does not match exactly, Godot logs:

```
ERROR: Can't open file from path 'res://.../TEX_Characters_White.png'.
```

Fix: rename the texture on disk to match the embedded name, or update the FBX import settings to point to the correct file.

### Animations may be bind pose only
Use a headless `SceneTree` debug script to inspect imported FBX content before assuming animations are usable:

```gdscript
extends SceneTree

func _init() -> void:
    var scene: PackedScene = load("res://assets/char/model.fbx")
    var instance: Node = scene.instantiate()
    _inspect(instance, 0)
    instance.queue_free()
    quit()

func _inspect(node: Node, depth: int) -> void:
    var indent: String = "  ".repeat(depth)
    print(indent + node.name + " (" + node.get_class() + ")")
    if node is AnimationPlayer:
        var anim_player: AnimationPlayer = node as AnimationPlayer
        var anims: PackedStringArray = anim_player.get_animation_list()
        print(indent + "  Animations [" + str(anims.size()) + "]: " + str(anims))
        for anim_name in anims:
            var anim: Animation = anim_player.get_animation(anim_name)
            print(indent + "    '" + anim_name + "': length=" + str(anim.length)
                  + ", tracks=" + str(anim.get_track_count()))
    for child in node.get_children():
        _inspect(child, depth + 1)
```

### Looping imported animations
Imported FBX animations do not loop by default. Set the loop mode in `_ready()`:

```gdscript
var anim: Animation = _animation_player.get_animation("Take 001")
if anim:
    anim.loop_mode = Animation.LOOP_LINEAR
```

### Triggering asset reimport headlessly
After adding new FBX/PNG assets, force Godot to generate `.import` files without opening the GUI:

```bash
godot --path ./src/my-project --editor --quit --headless
```

## Validation Checks Reference (validate_godot.py)
- Ensures `format=3` (Godot 4).
- Matches `load_steps` to resource count.
- Verifies all `ExtResource`/`SubResource` IDs.
- Blocks GDScript keywords in TSCN/TRES files.
- Enforces strict typing and return arrows `->` in GDScript.
- Blocks Godot 3 patterns (`yield`, `connect("string")`).
- Script location: `docs/skills/godot-gdscript/scripts/validate_godot.py`
