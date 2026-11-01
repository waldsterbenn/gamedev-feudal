
extends Node
@export var zone_container_path: NodePath
var zones: Array = []
var selected_index: int = -1
func _ready() -> void:
	var container = get_node_or_null(zone_container_path)
	if container:
		zones = container.get_children()
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_right"):
		selected_index = (selected_index + 1) % max(zones.size(), 1)
		_select_zone()
	elif Input.is_action_just_pressed("ui_left"):
		selected_index = (selected_index - 1 + max(zones.size(), 1)) % max(zones.size(), 1)
		_select_zone()
	elif Input.is_action_just_pressed("ui_down"):
		if selected_index >= 0 and zones.size() > selected_index:
			var zone = zones[selected_index]
			if zone.has_method("_on_input_event"):
				var node = zone.get_node("ZoneNode") if zone.has_node("ZoneNode") else zone
				# Minimal trigger for inspection
				EventBus.ui.zone_selected.emit(node.get_node("ZoneNode") if node.has_node("ZoneNode") else node)
func _select_zone() -> void:
	if selected_index >= 0 and selected_index < zones.size():
		var zone = zones[selected_index]
		var zi = zone.get_node("ZoneNode") if zone.has_node("ZoneNode") else zone
		if zi != null and "node_id" in zi:
			EventBus.ui.zone_selected.emit(zi)
