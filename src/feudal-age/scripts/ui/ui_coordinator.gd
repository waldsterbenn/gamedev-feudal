extends CanvasLayer
class_name UICoordinator

enum UIState { HUD_ONLY, INSPECTING_NODE, MODAL_MENU }
var current_ui_state: UIState = UIState.HUD_ONLY

@onready var zone_menu: Control = $ZoneInspectionMenu
@onready var options_menu: Control = $OptionsMenu
@onready var hud_message: Label = %HUDMessage

var _message_clear_timer: Timer

func _ready() -> void:
	EventBus.ui.zone_selected.connect(_on_zone_selected)
	EventBus.ui.message_logged.connect(_on_message_logged)
	# One-shot timer hides the toast a few seconds after each message
	_message_clear_timer = Timer.new()
	_message_clear_timer.one_shot = true
	_message_clear_timer.wait_time = 4.0
	_message_clear_timer.timeout.connect(func(): hud_message.text = "")
	add_child(_message_clear_timer)
	change_ui_state(UIState.HUD_ONLY)

func _on_message_logged(message: String, level: String) -> void:
	if hud_message == null:
		return
	hud_message.text = message
	hud_message.modulate = Color(1.0, 0.75, 0.4) if level == "warn" else Color(1, 1, 1)
	_message_clear_timer.start()

func _on_zone_selected(zone_node: ZoneNode) -> void:
	if zone_node != null:
		inspect_zone(zone_node.node_id)

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
