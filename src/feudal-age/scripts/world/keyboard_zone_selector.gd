
extends Node
@export var zone_container_path: NodePath = NodePath("../ZoneContainer")
var zones: Array = []
var selected_index: int = -1
func _ready() -> void:
	EventBus.ui.management_mode_changed.connect(_on_mode_changed)
	var container = get_node_or_null(zone_container_path)
	if container:
		zones = container.get_children()
var management_active: bool = false
func _on_mode_changed(active: bool) -> void:
	management_active = active
func _process(_delta: float) -> void:
	if not management_active: return
	# Number keys 1-9 select zone directly (no arrow conflict)
	for i in range(1, 10):
		if zones.size() > i - 1:
			if Input.is_key_just_pressed(KEY_1 + i - 1):
				selected_index = i - 1
				_select_zone()
	# Enter = open inspection
	if Input.is_action_just_pressed("ui_accept"):
		_select_zone()
	# B = trigger build (after inspection is open)
	if Input.is_key_just_pressed(KEY_B):
		if selected_index >= 0 and selected_index < zones.size():
			var zone = zones[selected_index]
			var zi = zone.get_node("ZoneNode") if zone.has_node("ZoneNode") else zone
			if zi != null and "node_id" in zi:
				EventBus.ui.zone_selected.emit(zi)
				# Direct build trigger for keyboard test
				var api = root.get_node("ServiceLocator").management_api if root.has_node("ServiceLocator") else null
				if api != null:
					var bp_path := "res://data/blueprints/tent.tres"
					if ResourceLoader.exists(bp_path):
						var bp = load(bp_path)
						var ok: bool = api.order_building(zi.node_id, bp)
						print("Keyboard Build result: ", ok)
func _select_zone() -> void:
	if selected_index >= 0 and selected_index < zones.size():
		var zone = zones[selected_index]
		var zi = zone.get_node("ZoneNode") if zone.has_node("ZoneNode") else zone
		if zi != null and "node_id" in zi:
			EventBus.ui.zone_selected.emit(zi)
