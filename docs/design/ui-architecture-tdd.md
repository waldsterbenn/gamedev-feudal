# Technical Design Document (TDD) — UI Architecture

## 1. Architectural Position & Structural Topology
The User Interface (UI) subsystem functions as an independent tracking view layer. In alignment with the project's strict compartmentalization architecture, the UI domain contains zero authority over game rules, economic data simulation, or input remapping variables. It reads snapshots from the service layer and relays transaction requests back to the background simulation engines.

### 1.1 UI Control Hierarchy
The UI system layout relies on Godot 4’s native `CanvasLayer` segregation. Fixed screens are isolated from spatial elements to eliminate performance overhead and render layer overlapping.


```text
[GameCoordinator Node]
 ├── UI (CanvasLayer) <--- [Attached: ui_coordinator.gd]
 │    ├── StandardHUD (Control)
 │    │    └── ResourceDisplayGrid (GridContainer)
 │    ├── ZoneInspectionMenu (PanelContainer) <-- Custom Inspector Menu
 │    └── OptionsMenu (PanelContainer)        <-- Pause Menu Overlay
 └── WorldSimulation (Node3D)

```

---

## 2. Component & Core Class Definitions

### 2.1 The UI Coordinator

The `UICoordinator` holds operational authority over all structural menu transformations.

```gdscript
# ui_coordinator.gd
extends CanvasLayer
class_name UICoordinator

enum UIState { HUD_ONLY, INSPECTING_NODE, MODAL_MENU }
var current_ui_state: UIState = UIState.HUD_ONLY

@onready var standard_hud: Control = $StandardHUD
@onready var zone_menu: Control = $ZoneInspectionMenu
@onready var options_menu: Control = $OptionsMenu

func _ready() -> void:
    change_ui_state(UIState.HUD_ONLY)

## Authoritative machine layout processor for UI screen visibility states
func change_ui_state(new_state: UIState) -> void:
    current_ui_state = new_state
    
    # Reset state allocations smoothly
    standard_hud.hide()
    zone_menu.hide()
    options_menu.hide()
    
    match current_ui_state:
        UIState.HUD_ONLY:
            standard_hud.show()
        UIState.INSPECTING_NODE:
            standard_hud.show()
            zone_menu.show()
        UIState.MODAL_MENU:
            options_menu.show()

func inspect_zone(node_id: int) -> void:
    change_ui_state(UIState.INSPECTING_NODE)
    zone_menu.open_inspection_window(node_id)

func close_menus() -> void:
    change_ui_state(UIState.HUD_ONLY)

```

### 2.2 Zone Inspection Menu Panel

Leverages Godot unique name links (`%`) to manipulate local structural fields without brittle scene path strings.

```gdscript
# zone_inspection_menu.gd
extends PanelContainer

@onready var name_label: Label = %NodeNameLabel
@onready var timber_label: Label = %TimberValueLabel
@onready var build_button: Button = %BuildButton

var _active_node_id: int = -1

func _ready() -> void:
    build_button.pressed.connect(_on_build_button_pressed)

func open_inspection_window(node_id: int) -> void:
    _active_node_id = node_id
    _refresh_display_metrics()

func _refresh_display_metrics() -> void:
    var api = ServiceLocator.get_management_service()
    if not api: return
    
    var data: Dictionary = api.get_node_inspection_data(_active_node_id)
    if data.is_empty():
        return
        
    name_label.text = data["node_name"]
    timber_label.text = str(data["timber_stock"])

func _on_build_button_pressed() -> void:
    var api = ServiceLocator.get_management_service()
    var tent_blueprint = preload("res://data/blueprints/tent.tres")
    
    if api and api.order_building(_active_node_id, tent_blueprint):
        _refresh_display_metrics()

```


## 3. Native Engine Tooltips

Tooltips rely completely on Godot's built-in control polling logic. Custom layouts override the native engine string drawing functionality directly.

```gdscript
# Attached to specialized action buttons requiring advanced breakdown layouts
extends Button

@export var contextual_description: String = "Costs 25 Timber."

func _make_custom_tooltip(for_text: String) -> Control:
    var tooltip_scene = preload("res://ui/components/fancy_tooltip.tscn").instantiate()
    tooltip_scene.get_node("DescriptionLabel").text = contextual_description
    return tooltip_scene

```