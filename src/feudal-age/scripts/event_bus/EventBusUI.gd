extends Node
class_name EventBusUI

# UI, HUD, and layout signals
signal message_logged(message: String, level: String)
signal management_mode_changed(is_active: bool)
signal zone_selected(zone_node: ZoneNode)
signal zone_deselected
signal blueprint_cycle_requested
signal debug_line(text: String)

## Shared debug channel: prints to the console AND feeds the in-game
## debug overlay. Use instead of bare print() for gameplay/UI debugging.
func debug(text: String) -> void:
	print("DEBUG: " + text)
	debug_line.emit(text)