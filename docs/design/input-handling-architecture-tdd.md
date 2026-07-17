# Technical Design Document (TDD) — Input Handling Architecture

| Architecture Tier | Component Category | Primary Interface | Engine Framework |
| :--- | :--- | :--- | :--- |
| Core Subsystem | Event Gatekeeper | Unidirectional Pipeline | Godot Native InputMap |

---

## 1. Architectural Position & Native Engine Layering

The Input system serves as a unidirectional event gatekeeper. It listens directly to the hardware level, references the state boundaries dictated by the `UICoordinator`, and dispatches commands. It bypasses scene tree pathways completely by using Godot's native configuration framework.


```

[Hardware Level] ➔ [Input System] ➔ [UICoordinator State Check] ➔ [Command Dispatch]

```

### 1.1 The Input Map Configuration Rule

> **CRITICAL CONSTRAINT:** No hardcoded key code constants (e.g., `KEY_ESCAPE`, `KEY_W`) are allowed within execution logic blocks. All interactions must map directly to an entry configured inside **Project Settings ➔ Input Map**.

#### Core Input Map Profiles
* `ui_cancel` ➔ Intercepts `[Escape]` key sequences globally.
* `interact_select` ➔ Intercepts left-click mouse inputs.
* `move_camera_forward` ➔ Intercepts structural axis changes.

---

## 2. Component & Core Class Definitions

### 2.1 The Input Router
The `InputRouter` operates as an execution branch component attached right below the `GameCoordinator` level. It filters structural input execution trees based on layout state configurations.

```gdscript
# input_router.gd
extends Node
class_name InputRouter

@onready var ui_coordinator: UICoordinator = $"../UI"

func _unhandled_input(event: InputEvent) -> void:
    # Priority 1: Check for global application macro requests
    if event.is_action_pressed("force_quit"):
        get_tree().quit()
        return
        
    # Priority 2: Filter input execution trees by layout state configurations
    match ui_coordinator.current_ui_state:
        UICoordinator.UIState.MODAL_MENU:
            _process_modal_menu_inputs(event)
        UICoordinator.UIState.INSPECTING_NODE:
            _process_inspection_view_inputs(event)
        UICoordinator.UIState.HUD_ONLY:
            _process_standard_gameplay_inputs(event)

func _process_modal_menu_inputs(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        ui_coordinator.close_menus()

func _process_inspection_view_inputs(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        ui_coordinator.close_menus()
    _process_environmental_selection_inputs(event)

func _process_standard_gameplay_inputs(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        ui_coordinator.change_ui_state(UICoordinator.UIState.MODAL_MENU)
        return
    _process_environmental_selection_inputs(event)

func _process_environmental_selection_inputs(event: InputEvent) -> void:
    if event.is_action_pressed("interact_select"):
        # Dispatch direct 3D physical coordinate check algorithms here
        _evaluate_spatial_raycast_selection()

```

---

## 3. Dynamic Runtime Control Rebinding

The system fully supports dynamic runtime key rebinding by mutating Godot’s native engine registry directly via code. No external text-parsing configurations are necessary; instead, rebind arrays are written out straight to native engine resources (`user://input_config.cfg`).

```gdscript
# control_rebind_service.gd
extends Node
class_name ControlRebindService

## Mutates the native project engine configuration settings dynamically
static func rebind_action(action_name: String, new_input_event: InputEvent) -> void:
    if not InputMap.has_action(action_name):
        print("InputRouter: Requested rebinding action does not exist: ", action_name)
        return
        
    # Clear old keys to prevent double-mapping conflicts
    InputMap.action_erase_events(action_name)
    
    # Commit the fresh physical event register straight into the engine mapping table
    InputMap.action_add_event(action_name, new_input_event)
    
    _serialize_rebinds_to_disk()

static func _serialize_rebinds_to_disk() -> void:
    # Saves altered key configs cleanly using Godot's configuration file interface
    var config = ConfigFile.new()
    for action in InputMap.get_actions():
        if action.begins_with("ui_") and not action == "ui_cancel": 
            continue # Bypass native editor mappings safely
            
        var events = InputMap.action_get_events(action)
        if events.size() > 0:
            config.set_value("Keybindings", action, events[0])
            
    config.save("user://input_config.cfg")
```

---

## 4. Design Philosophy (Input & Simulation Separation)

No raw hardware key strings are hardcoded into functional code. All incoming hardware signals flow natively through Godot's built-in Input Map configuration table (the `InputRouter` script intercepts unhandled input and evaluates the player's active state boundaries to route commands contextually):

* **If a menu screen is blocking gameplay:** Input maps exclusively to `UICoordinator` actions (e.g., closing a panel, cycling tabs, or selecting buttons).
* **If no screens are blocking gameplay:** Input routes directly to simulation triggers (e.g., commanding the 3D camera to pan or triggering raycasts onto `ZoneAnchor3D` nodes).
```