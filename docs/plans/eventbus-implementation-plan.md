# EventBus Implementation Plan

This plan details how to properly implement a production-grade, modular `EventBus` as a reusable scene inside the main active project `src/feudal-age/`.

---

## 1. Architectural Approach: Scene-Tree Sub-Buses

Instead of a single flat script with hundreds of unrelated signals, we will leverage Godot's scene-tree composition. The `EventBus` will be a **reusable scene (`.tscn`)** with specialized child category nodes. 

This provides clean namespaces, distributes code ownership, and makes the system easily extensible.

### Scene-Tree Hierarchy:
```
EventBus (Node, EventBus.gd)
├── UI (Node, EventBusUI.gd)         <-- For HUD, menus, layout changes
├── Audio (Node, EventBusAudio.gd)   <-- For SFX, music transitions, ambient cues
└── VFX (Node, EventBusVFX.gd)       <-- For screen shake, weather triggers, particles
```

### Runtime Node Hierarchy Placement:
When registered as an Autoload in `project.godot`, Godot mounts the `EventBus.tscn` scene directly under the root Viewport (`/root`). It sits parallel to other global autoloads and above the active gameplay scene (`World`):

```
[Viewport Root: /root]
 ├── ServiceLocator (Autoload Node)
 ├── ManagementAPI (Autoload Node)
 ├── EventBus (Autoload Node, res://scenes/event_bus/EventBus.tscn)
 │    ├── UI (Node, res://scripts/event_bus/EventBusUI.gd)
 │    ├── Audio (Node, res://scripts/event_bus/EventBusAudio.gd)
 │    └── VFX (Node, res://scripts/event_bus/EventBusVFX.gd)
 └── World (Main Scene Tree Root)
      └── GameCoordinator (Node)
           ├── ManagementModule (Node)
           └── SocialModule (Node)
```

**Key Hierarchy Characteristics**:
* **Position**: Sits at `/root/EventBus` in the global runtime hierarchy.
* **Isolation**: Lives completely outside the `World` / `GameCoordinator` subtree, ensuring that loading, unloading, or resetting world scenes never destroys or resets the event bus.
* **Global Access**: Accessible anywhere in GDScript using the global singleton name `EventBus` (or `EventBus.ui`, `EventBus.audio`, `EventBus.vfx`).

### Namespace Cleanliness:
Core code emits signals on logical child namespaces:
* `EventBus.ui.management_mode_changed.emit(true)`
* `EventBus.audio.sfx_played.emit("click")`
* `EventBus.vfx.screen_shake_requested.emit(0.5)`

---

## 2. File Topology

We will create the following files under the `src/feudal-age/` project root:

1. **Scene File**:
   * `scenes/event_bus/EventBus.tscn` — The reusable scene representing the bus.
2. **Scripts**:
   * `scripts/event_bus/EventBus.gd` — Root controller that references the sub-bus nodes.
   * `scripts/event_bus/EventBusUI.gd` — Handles UI/presentation-related signals.
   * `scripts/event_bus/EventBusAudio.gd` — Handles sound effect/music trigger signals.
   * `scripts/event_bus/EventBusVFX.gd` — Handles visual feedback/effects signals.

---

## 3. Implementation Details

### `EventBus.gd` (Root)
```gdscript
extends Node

@onready var ui: EventBusUI = $UI
@onready var audio: EventBusAudio = $Audio
@onready var vfx: EventBusVFX = $VFX

func _ready() -> void:
	print("EventBus: Core bus initialized successfully.")
```

### `EventBusUI.gd` (UI Sub-bus)
```gdscript
extends Node
class_name EventBusUI

signal message_logged(message: String, level: String)
signal management_mode_changed(is_active: bool)
signal zone_selected(zone_node: ZoneNode)
```

### `EventBusAudio.gd` (Audio Sub-bus)
```gdscript
extends Node
class_name EventBusAudio

signal play_sfx(sfx_id: String)
signal play_music(track_id: String)
```

### `EventBusVFX.gd` (VFX Sub-bus)
```gdscript
extends Node
class_name EventBusVFX

signal camera_shake_requested(intensity: float, duration: float)
```

---

## 4. Integration & Registration

### Step A: Register the Autoload
We will add the scene to the `[autoload]` section of [project.godot](file:///C:/Users/woodl/GitHub/gamedev-feudal/src/feudal-age/project.godot):
```ini
EventBus="*res://scenes/event_bus/EventBus.tscn"
```

### Step B: Replace Legacy TODOs
We will resolve all `# TODO(event-system)` markers across the active `feudal-age` scripts:

1. **[Player.gd](file:///C:/Users/woodl/GitHub/gamedev-feudal/src/feudal-age/scripts/player/Player.gd)**:
   ```gdscript
   func _ready() -> void:
       # ...
       EventBus.ui.message_logged.emit("Player initialized", "info")
   ```

2. **[InteractableComponent.gd](file:///C:/Users/woodl/GitHub/gamedev-feudal/src/feudal-age/scripts/core/InteractableComponent.gd)**:
   ```gdscript
   func interact(interactor: Node3D) -> void:
       interacted.emit(interactor)
       EventBus.ui.message_logged.emit("Interacted with: " + interaction_name, "info")
   ```

3. **[management_mode_controller.gd](file:///C:/Users/woodl/GitHub/gamedev-feudal/src/feudal-age/scripts/ui/management_mode_controller.gd)**:
   ```gdscript
   func _unhandled_input(event: InputEvent) -> void:
       if event.is_action_pressed("toggle_management"):
           _management_active = not _management_active
           EventBus.ui.management_mode_changed.emit(_management_active)
   ```

4. **[ZoneAnchor3D.gd](file:///C:/Users/woodl/GitHub/gamedev-feudal/src/feudal-age/scripts/world/ZoneAnchor3D.gd)**:
   * Subscribe in `_ready()`:
     ```gdscript
     EventBus.ui.management_mode_changed.connect(_on_management_mode_changed)
     ```
   * Emit selection on click:
     ```gdscript
     EventBus.ui.zone_selected.emit(zone_node)
     ```
   * Log building completion:
     ```gdscript
     EventBus.ui.message_logged.emit("Building completed in node %d: %s" % [zone_node.node_id, building_id], "info")
     ```
