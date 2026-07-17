extends CanvasLayer
class_name UICoordinator

enum UIState { HUD_ONLY, INSPECTING_NODE, MODAL_MENU }
var current_ui_state: UIState = UIState.HUD_ONLY

@onready var standard_hud: Control = $StandardHUD
@onready var zone_menu: Control = $ZoneInspectionMenu
@onready var options_menu: Control = $OptionsMenu

func _ready() -> void:
	EventBus.zone_selected.connect(inspect_zone)
	EventBus.zone_deselected.connect(close_menus)
	change_ui_state(UIState.HUD_ONLY)

## Authoritative state machine — resets all panels then shows what's needed
func change_ui_state(new_state: UIState) -> void:
	current_ui_state = new_state

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
