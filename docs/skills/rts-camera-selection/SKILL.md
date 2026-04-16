---
name: rts-camera-selection
description: A collection of camera controllers and selection systems for real-time
  strategy games, providing:.
license: MIT (assumed)
compatibility: Godot 4.x, Feudal Game project
tags:
- godot
- plugin
- feudal-game
metadata:
  reference: https://github.com/carmel4a/RTS-Camera2D
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
