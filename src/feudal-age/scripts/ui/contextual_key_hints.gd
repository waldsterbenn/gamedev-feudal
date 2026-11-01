extends Node
class_name ContextualKeyHints

## Single-responsibility component: decides WHICH key hints belong to the
## current UI state. Subscribes to EventBus signals only — no parent queries.
## UICoordinator owns the Label; this component owns the hint LISTS.
##
## Data-driven per state: each UI state maps to an ordered list of hint
## keys from keybindings.tres (single source of truth), rendered as
## "KEY = description" lines.

const HINTS := {
	# Nothing open: only the entry point into management mode.
	"HUD_ONLY": [
		{"key": "management_mode", "text": "Management mode"},
	],
	# Management overlay is on: the zone-navigation loop. Zone selection
	# feeds inspection, so the full loop is relevant here.
	"MANAGEMENT": [
		{"key": "management_mode", "text": "Exit management mode"},
		{"key": "select_zone", "text": "Select zone"},
		{"key": "inspect_zone", "text": "Inspect zone"},
	],
	# Inspection panel open: panel is self-explaining (buttons show their
	# own keys), so only the navigation keys not on buttons are listed.
	"INSPECTING_NODE": [
		{"key": "close_menu", "text": "Close panel"},
	],
	# Modal menu open.
	"MODAL_MENU": [
		{"key": "close_menu", "text": "Close menu"},
	],
}

var _current_state: String = "HUD_ONLY"
var _management_active: bool = false

func _ready() -> void:
	EventBus.ui.zone_selected.connect(func(_zone): set_state("INSPECTING_NODE"))
	EventBus.ui.zone_deselected.connect(_on_zone_deselected)
	EventBus.ui.management_mode_changed.connect(_on_management_mode_changed)

func _on_management_mode_changed(active: bool) -> void:
	_management_active = active
	# Opening inspection keeps INSPECTING (zone_selected fires after the
	# mode toggle); otherwise follow the mode directly.
	if _current_state != "INSPECTING_NODE":
		set_state("MANAGEMENT" if active else "HUD_ONLY")

func _on_zone_deselected() -> void:
	# Panel closed: return to the management loop if the overlay is still
	# on, plain HUD when it isn't.
	set_state("MANAGEMENT" if _management_active else "HUD_ONLY")

## Replaces the hint list for the current UI state
func set_state(state: String) -> void:
	if state == _current_state:
		return
	_current_state = state
	hints_changed.emit()

signal hints_changed

## Returns the rendered hint lines for the current state
func get_hint_lines() -> Array[String]:
	var bindings: KeyBindingSet = load("res://data/ui/keybindings.tres")
	var lines: Array[String] = []
	if bindings == null:
		return lines
	for hint in HINTS.get(_current_state, []):
		lines.append("%s = %s" % [bindings.get_display(hint["key"]), hint["text"]])
	return lines
