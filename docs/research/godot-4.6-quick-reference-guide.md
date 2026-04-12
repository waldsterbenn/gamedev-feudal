# Godot 4.6 Quick Reference Guide
## Best Practices and Patterns

### Core Concepts
- **Nodes**: Basic building blocks of scenes
- **Scenes**: Collections of nodes forming game elements
- **Resources**: Data assets (textures, sounds, scripts, etc.)
- **Signals**: Communication system between nodes
- **Scripts**: Code that adds behavior to nodes

---

## Project Structure

### Directory Organization
```
project/
├── scenes/           # All scene files
├── scripts/         # All script files
├── assets/          # Sprites, models, audio, etc.
├── resources/       # Reusable resources (.tres files)
├── ui/             # User interface specific files
├── shaders/        # Custom shader files
├── levels/         # Level-specific content
└── tools/          # Development tools and utilities
```

### Naming Conventions
- **Scenes/Nodes**: PascalCase (e.g., `PlayerController.tscn`)
- **Scripts/Variables**: snake_case (e.g., `player_health.gd`)
- **Constants**: UPPER_CASE (e.g., `MAX_HEALTH`)
- **Resources**: Descriptive names with .tres extension

---

## Key Patterns

### 1. Singleton Pattern (Autoload)
```gdscript
# GameSingleton.gd
extends Node

var score = 0
var current_level = 1

signal score_changed(new_score)

func _ready():
    reset_game_state()

func reset_game_state():
    score = 0
    current_level = 1
    emit_signal("score_changed", score)
```

### 2. State Machine Pattern
```gdscript
# StateMachine.gd
extends Node

var current_state = null
var states = {}

func _ready():
    for child in get_children():
        states[child.name] = child

func change_state(new_state_name):
    if current_state:
        current_state.exit()
    current_state = states[new_state_name]
    current_state.enter()

func _process(delta):
    if current_state:
        current_state.update(delta)
```

### 3. Object Pool Pattern
```gdscript
# ObjectPool.gd
extends Node

var pool = []
var pool_scene = null

func get_object():
    if pool.size() > 0:
        return pool.pop_back()
    else:
        return pool_scene.instance()

func return_object(obj):
    obj.visible = false
    obj.position = Vector2.ZERO
    pool.append(obj)
```

### 4. Scene Management
```gdscript
# SceneManager.gd
extends Node

var current_scene = null

func change_scene(scene_path):
    var transition = load("res://scenes/Transition.tscn").instance()
    add_child(transition)
    yield(transition, "transition_complete")
    get_tree().change_scene(scene_path)
    transition.queue_free()
```

---

## Performance Optimization

### Rendering
- ✅ Use instancing for similar objects
- ✅ Implement texture atlases
- ✅ Use LOD for 3D models
- ✅ Optimize shaders
- ❌ Avoid unnecessary transparency
- ❌ Don't overdraw

### Memory
- ✅ Compress textures (ASTC for mobile, BC for desktop)
- ✅ Load resources asynchronously
- ✅ Implement proper unloading
- ✅ Use object pooling
- ❌ Don't create/destroy objects frequently
- ❌ Don't leak memory

### Physics
- ✅ Use simple collision shapes
- ✅ Implement physics layers
- ✅ Use area-based collision where possible
- ❌ Don't overuse continuous collision detection
- ❌ Don't make physics engine step too small

---

## Scripting Best Practices

### GDScript Optimization
```gdscript
# GOOD: Cached references
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D

# GOOD: Use constants
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# GOOD: Process efficiently
func _physics_process(delta):
    var direction = Input.get_axis("move_left", "move_right")
    velocity.x = direction * SPEED
    move_and_slide()
```

### Anti-Patterns to Avoid
```gdscript
# BAD: Expensive operations in _process()
func _process(delta):
    var result = heavy_computation()  # Don't do this!
    update_ui(result)

# BAD: Global variables
var global_player_data = {}  # Don't use globals!

# BAD: No error handling
func get_node(path):
    var node = get_tree().get_node(path)  # Could be null!
    return.node  # Crash!
```

---

## Input Handling

### Input Manager
```gdscript
# InputManager.gd
extends Node

func get_input(action_name):
    return Input.is_action_pressed(action_name)

func get_input_vector(horizontal, vertical):
    var h = get_input(horizontal) ? 1 : 0
    var v = get_input(vertical) ? 1 : 0
    return Vector2(h, v)
```

### Input Mapping Setup
```
[actions]
move_left=ui_left
move_right=ui_right
jump=ui_accept
attack=ui_select
```

---

## UI Patterns

### UI Manager
```gdscript
# UIManager.gd
extends Node

var current_screen = null

func show_screen(screen_name):
    if current_screen:
        current_screen.hide()
    current_screen = get_node(screen_name)
    current_screen.show()
```

### UI State Management
- Use separate state for UI elements
- Handle visibility properly
- Implement proper event handling
- Use containers for layout

---

## Save/Load System

### Save Manager
```gdscript
# SaveManager.gd
extends Node

const SAVE_FILE_PATH = "user://savegame.save"

func save_game(data):
    var file = File.new()
    file.open(SAVE_FILE_PATH, File.WRITE)
    file.store_line(to_json(data))
    file.close()

func load_game():
    var file = File.new()
    if file.file_exists(SAVE_FILE_PATH):
        file.open(SAVE_FILE_PATH, File.READ)
        var data = parse_json(file.get_line())
        file.close()
        return data
    return null
```

---

## Debugging Tools

### Debug Manager
```gdscript
# DebugManager.gd
extends Node

var debug_mode = true

func _process(delta):
    if debug_mode:
        print("FPS: ", Engine.get_frames_per_second())
        print("Memory: ", Performance.get_monitor(Performance.MEMORY_STATIC))
```

### Profiling
- Use built-in profiler
- Monitor FPS and memory
- Check draw calls
- Profile on target platform

---

## Testing Checklist

### Pre-Development
- [ ] Project structure setup
- [ ] Input mappings configured
- [ ] Resource management system
- [ ] Scene management system
- [ ] State management system

### Development
- [ ] Naming conventions followed
- [ ] Code organized properly
- [ ] Error handling implemented
- [ ] Debug tools added
- [ ] Performance profiling

### Testing
- [ ] Test on target platforms
- [ ] Profile performance
- [ ] Test save/load systems
- [ ] Test input handling
- [ ] Test edge cases

### Deployment
- [ ] Assets optimized for platform
- [ ] Performance tested on hardware
- [ ] Error reporting implemented
- [ ] Documentation created
- [ ] Build pipeline set up

---

## Common Issues and Solutions

### Performance Issues
**Problem**: Low FPS
- Solution: Profile to find bottlenecks, optimize draw calls, simplify shaders

**Problem**: High memory usage
- Solution: Check for leaks, implement unloading, optimize textures

### Scene Issues
**Problem**: Scene loading problems
- Solution: Check paths, verify dependencies, handle errors

**Problem**: Memory leaks
- Solution: Check circular references, implement cleanup

### Script Issues
**Problem**: Node reference errors
- Solution: Use proper path validation, check for null references

**Problem**: Performance problems
- Solution: Avoid expensive operations in _process(), cache references

---

## Resources

### Official Documentation
- https://docs.godotengine.org/en/stable/
- https://github.com/godotengine/godot/releases
- https://docs.godotengine.org/en/stable/classes/

### Community Resources
- https://godotengine.org/learn/
- https://github.com/topics/godot-game-development
- https://godotengine.org/community/

### Tools
- Built-in profiler
- Frame debugger
- Memory profiler
- RenderDoc (for GPU debugging)

---

## Quick Reference Commands

### Scene Management
- `get_tree().change_scene("path/to/scene.tscn")` - Change scene
- `preload("path/to/scene.tscn").instance()` - Preload scene
- `add_child(node)` - Add node to scene
- `remove_child(node)` - Remove node from scene

### Input
- `Input.is_action_pressed("action_name")` - Check input
- `Input.get_axis("negative", "positive")` - Get axis input

### File Operations
- `File.new()` - Create file object
- `file.open(path, mode)` - Open file
- `file.store_line(data)` - Write line
- `file.get_line()` - Read line

### Performance
- `Engine.get_frames_per_second()` - Get FPS
- `Performance.get_monitor(type)` - Get performance data

---

*This quick reference guide provides essential patterns and best practices for Godot 4.6 game development. Use it as a quick reference during development.*