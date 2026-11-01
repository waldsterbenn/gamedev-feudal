extends Node
@export var zone_container_path: NodePath = NodePath("../ZoneContainer")
var selected_index: int = -1
var management_active: bool = false

func _ready() -> void:
	EventBus.ui.management_mode_changed.connect(_on_mode_changed)

func _on_mode_changed(active: bool) -> void:
	management_active = active
	if active:
		_refresh_zones()

func _refresh_zones() -> void:
	var container = get_node_or_null(zone_container_path)
	if container:
		# Get all ZoneAnchor3D children
		var all_children = container.get_children()
		var new_zones = []
		for child in all_children:
			if child is ZoneAnchor3D or child.has_node("ZoneNode") or "node_id" in child:
				new_zones.append(child)
		print("DEBUG: Keyboard selector found ", new_zones.size(), " zones")
		# Reset selection if current selection is out of bounds
		if selected_index >= new_zones.size():
			selected_index = -1

func _process(_delta: float) -> void:
	if not management_active: return
	# Number keys 1-9 select zone directly (no arrow conflict)
	for i in range(1, 10):
		var zones = _get_zones()
		if zones.size() > i - 1:
			if Input.is_key_just_pressed(KEY_1 + i - 1):
				selected_index = i - 1
				_select_zone()
	# Enter = open inspection
	if Input.is_action_just_pressed("ui_accept"):
		_select_zone()
	# B = trigger build (after inspection is open)
	if Input.is_key_just_pressed(KEY_B):
		var zones = _get_zones()
		if selected_index >= 0 and selected_index < zones.size():
			var zone = zones[selected_index]
			var zi = zone.get_node("ZoneNode") if zone.has_node("ZoneNode") else zone
			if zi != null and "node_id" in zi:
				EventBus.ui.zone_selected.emit(zi)
				# Direct build trigger for keyboard test
				var root_node = get_tree().get_root()
				var api = root_node.get_node("ServiceLocator").management_api if root_node.has_node("ServiceLocator") else null
				if api != null:
					var bp_path := "res://data/blueprints/tent.tres"
					if ResourceLoader.exists(bp_path):
						var bp = load(bp_path)
						var ok: bool = api.order_building(zi.node_id, bp)
						print("Keyboard Build result: ", ok)

func _get_zones() -> Array:
	var container = get_node_or_null(zone_container_path)
	if container:
		var all_children = container.get_children()
		var zones = []
		for child in all_children:
			if child is ZoneAnchor3D or child.has_node("ZoneNode") or "node_id" in child:
				zones.append(child)
		return zones
	return []

func _select_zone() -> void:
	var zones = _get_zones()
	if selected_index >= 0 and selected_index < zones.size():
		var zone = zones[selected_index]
		var zi = zone.get_node("ZoneNode") if zone.has_node("ZoneNode") else zone
		if zi != null and "node_id" in zi:
			print("DEBUG: Selecting zone ", selected_index, " node_id=", zi.node_id)
			EventBus.ui.zone_selected.emit(zi)