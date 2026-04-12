---
name: godot-gdscript
description: Use this skill when working on any Godot 4.6 task — writing GDScript, creating or editing .tscn scene files, .tres resource files, or debugging scene load failures. Keywords: godot, gdscript, tscn, tres, scene, node, signal, CharacterBody2D, export, resource, instancing.
---

# Godot 4.6 — GDScript & Scene Authoring

## MANDATORY: Validate After Every File Write

After writing or editing any `.tscn`, `.tres`, or `.gd` file, run:

```
python scripts/validate_godot.py <path/to/file>
```

To validate the whole project at once:
```
python scripts/validate_godot.py --all
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

### Complete working example
```
[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://scripts/player.gd" id="1"]

[sub_resource type="CapsuleShape2D" id="CapsuleShape2D_1"]
radius = 16.0
height = 48.0

[node name="Player" type="CharacterBody2D"]
script = ExtResource("1")

[node name="Sprite2D" type="Sprite2D" parent="."]

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("CapsuleShape2D_1")
```

Note: `load_steps=3` because 1 ext_resource + 1 sub_resource + 1 = 3.

---

## What NEVER Goes in a .tscn or .tres File

```
# These will silently corrupt or fail to load the scene:
preload("res://...")          ← use ExtResource("id") instead
var speed = 100               ← GDScript keyword, not valid here
const MAX = 10                ← GDScript keyword, not valid here
func _ready():                ← GDScript keyword, not valid here
@export var x                 ← GDScript decorator, not valid here
```

---

## TRES Resource Files

```
[gd_resource type="ItemData" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/item_data.gd" id="1"]

[resource]
script = ExtResource("1")
item_name = "Sword"
damage = 25
icon = null
```

Same rules as TSCN: no GDScript syntax, no `preload()`.

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

# WRONG
var speed = 200.0
func get_damage():
    return _damage
```

### Script section order
```gdscript
class_name PlayerController
extends CharacterBody2D

# 1. signals
signal health_changed(new_health: int)
signal died

# 2. enums
enum State { IDLE, RUNNING, JUMPING, DEAD }

# 3. constants
const MAX_HEALTH: int = 100

# 4. exports
@export var speed: float = 200.0
@export var jump_force: float = 450.0

# 5. public vars
var current_state: State = State.IDLE

# 6. private vars
var _health: int = MAX_HEALTH

# 7. onready
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# 8. built-in callbacks
func _ready() -> void:
    pass

func _physics_process(delta: float) -> void:
    pass

# 9. public functions
func take_damage(amount: int) -> void:
    _health -= amount
    health_changed.emit(_health)
    if _health <= 0:
        _die()

# 10. private functions
func _die() -> void:
    died.emit()
    queue_free()
```

---

## Signals — Godot 4 Syntax Only

```gdscript
# Declare
signal health_changed(new_health: int)

# Emit
health_changed.emit(_health)

# Connect
func _ready() -> void:
    button.pressed.connect(_on_button_pressed)
    area.body_entered.connect(_on_body_entered)

# Handler
func _on_button_pressed() -> void:
    pass
```

**Godot 3 syntax — never use any of these:**
```gdscript
connect("health_changed", self, "_on_health_changed")  # WRONG
emit_signal("health_changed", value)                    # WRONG
yield(timer, "timeout")                                 # WRONG
onready var x                                           # WRONG — no @
export var x                                            # WRONG — no @
```

---

## Common Patterns

### CharacterBody2D movement
```gdscript
func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity += get_gravity() * delta
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = -jump_force
    velocity.x = Input.get_axis("move_left", "move_right") * speed
    move_and_slide()
```

### Instancing scenes
```gdscript
const BULLET: PackedScene = preload("res://scenes/bullet.tscn")

func _shoot() -> void:
    var bullet: Bullet = BULLET.instantiate()
    bullet.global_position = $Muzzle.global_position
    get_tree().current_scene.add_child(bullet)
```

### Safe tree modifications
```gdscript
queue_free()                          # safe — deferred by default
call_deferred("add_child", node)      # safe — deferred
# Never call free() or add_child() directly inside physics body loops
```

### Awaiting
```gdscript
await get_tree().create_timer(1.5).timeout
await animation_player.animation_finished
```

---

## Validation Checks Reference

The `validate_godot.py` script checks for:

**TSCN/TRES:**
- Header starts with `[gd_scene` or `[gd_resource`
- `format=3` present (Godot 4)
- `load_steps` matches actual resource count
- All `ExtResource("id")` references have matching declarations
- All `SubResource("id")` references have matching declarations
- No GDScript syntax (`preload`, `var`, `func`, `const`, `@export`, `@onready`)
- Root node has no `parent=` attribute
- Parent paths don't include root node name

**GDScript:**
- Untyped `var` declarations
- Functions missing return type arrows `-> Type`
- Godot 3 patterns: `yield`, old `connect()`, `emit_signal()`, `onready`, `export`
- `@onready` without type hint
- Dangerous `free()` near physics callbacks
