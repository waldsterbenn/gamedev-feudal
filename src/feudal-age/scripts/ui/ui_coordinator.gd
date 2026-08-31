extends CanvasLayer
class_name UICoordinator

enum UIState { HUD_ONLY, INSPECTING_NODE, MODAL_MENU }
var current_ui_state: UIState = UIState.HUD_ONLY

@onready var zone_menu: Control = $ZoneInspectionMenu
@onready var options_menu: Control = $OptionsMenu

func _ready() -> void:
	# TODO(event-system): subscribe to zone select/deselect via the replacement for legacy EventBus
	change_ui_state(UIState.HUD_ONLY)

## Authoritative state machine — resets all panels then shows what's needed
func change_ui_state(new_state: UIState) -> void:
	current_ui_state = new_state

	zone_menu.hide()
	options_menu.hide()

	match current_ui_state:
		UIState.HUD_ONLY:
			pass
		UIState.INSPECTING_NODE:
			zone_menu.show()
		UIState.MODAL_MENU:
			options_menu.show()

func inspect_zone(node_id: int) -> void:
	change_ui_state(UIState.INSPECTING_NODE)
	zone_menu.open_inspection_window(node_id)

func close_menus() -> void:
	change_ui_state(UIState.HUD_ONLY)
