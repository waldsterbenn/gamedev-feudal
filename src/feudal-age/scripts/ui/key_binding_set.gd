extends Resource
class_name KeyBindingSet

## Single source of truth for UI shortcut keys.
## Values are Godot keycode strings (e.g. "KEY_E", "KEY_ESCAPE").
## The keyboard selector polls these keycodes and the UI composes
## button labels from them — never hardcode a key in both places.

@export var bindings: Dictionary = {
	"management_mode": "KEY_TAB",
	"select_zone": "KEY_1-9",
	"inspect_zone": "KEY_ENTER",
	"establish_camp": "KEY_E",
	"order_building": "KEY_B",
	"post_forager": "KEY_F",
	"post_woodcutter": "KEY_G",
	"close_menu": "KEY_ESCAPE",
	"debug_overlay": "KEY_F12",
}

## Returns the Key constant for an action, or KEY_NONE if unmapped/unparsed
func get_key(action: String) -> Key:
	var code_name: String = bindings.get(action, "")
	var key: Key = OS.find_keycode_from_string(code_name)
	if key == Key.KEY_NONE and code_name.begins_with("KEY_"):
		# Tolerate legacy "KEY_E" style entries by stripping the prefix
		key = OS.find_keycode_from_string(code_name.substr(4))
	return key

## Short human label for UI display: "E", "Esc", "Tab"
func get_display(action: String) -> String:
	var key: Key = get_key(action)
	match key:
		Key.KEY_ESCAPE:
			return "Esc"
		Key.KEY_TAB:
			return "Tab"
		Key.KEY_ENTER:
			return "Enter"
		Key.KEY_NONE:
			return "?"
	return OS.get_keycode_string(key)