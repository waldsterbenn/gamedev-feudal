extends Node
class_name EventBusUI

# UI, HUD, and layout signals
signal message_logged(message: String, level: String)
signal management_mode_changed(is_active: bool)
signal zone_selected(zone_node: ZoneNode)
