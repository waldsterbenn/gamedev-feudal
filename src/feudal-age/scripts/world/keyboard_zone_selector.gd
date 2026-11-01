extends Node
@export var zone_container_path: NodePath = NodePath("../ZoneContainer")
var selected_index: int = -1
var management_active: bool = false
var _prev_key_states: Dictionary = {}

func _ready() -> void:
	EventBus.ui.management_mode_changed.connect(_on_mode_changed)

func _on_mode_changed(active: bool) -> void:
	management_active = active
	if active:
		_refresh_zones()

func _refresh_zones() -> void:
	var zones := _get_zones()
	print("DEBUG: Keyboard selector found ", zones.size(), " zones")
	if selected_index >= zones.size():
		selected_index = -1

func _process(_delta: float) -> void:
	if not management_active:
		return
	var zones := _get_zones()
	# Number keys 1-9 select zone directly (no arrow/movement conflict)
	for i in range(1, 10):
		if zones.size() > i - 1 and _is_key_just_pressed(KEY_1 + i - 1):
			selected_index = i - 1
			_select_zone(zones)
	# Enter = open inspection on selected zone
	if Input.is_action_just_pressed("ui_accept"):
		_select_zone(zones)
	# E = Establish Camp on selected zone (wilderness only)
	if _is_key_just_pressed(KEY_E):
		_establish_camp_on_selected(zones)
	# B = trigger build on selected zone
	if _is_key_just_pressed(KEY_B):
		_build_on_selected(zones)
	# F = post 2 forager jobs on selected zone (camp only)
	if _is_key_just_pressed(KEY_F):
		_post_forager_on_selected(zones)

## Returns the ZoneAnchor3D children of the zone container
func _get_zones() -> Array:
	var container = get_node_or_null(zone_container_path)
	if container == null:
		return []
	var zones := []
	for child in container.get_children():
		if child is ZoneAnchor3D:
			zones.append(child)
	return zones

func _select_zone(zones: Array) -> void:
	if selected_index < 0 or selected_index >= zones.size():
		return
	var anchor: ZoneAnchor3D = zones[selected_index]
	if anchor.zone_node != null:
		print("DEBUG: Selecting zone ", selected_index, " node_id=", anchor.zone_node.node_id, " name=", anchor.zone_node.node_name)
		EventBus.ui.zone_selected.emit(anchor.zone_node)

func _build_on_selected(zones: Array) -> void:
	if selected_index < 0 or selected_index >= zones.size():
		print("DEBUG: Build pressed but no zone selected — press 1-9 first")
		return
	var anchor: ZoneAnchor3D = zones[selected_index]
	if anchor.zone_node == null:
		return
	EventBus.ui.zone_selected.emit(anchor.zone_node)
	var api = ServiceLocator.get_management_service()
	if api == null:
		print("DEBUG: Build failed — ManagementAPI not available")
		return
	var bp_path := "res://data/blueprints/tent.tres"
	if not ResourceLoader.exists(bp_path):
		print("DEBUG: Build failed — blueprint missing")
		return
	var bp = load(bp_path)
	var ok: bool = api.order_building(anchor.zone_node.node_id, bp)
	print("DEBUG: Keyboard Build result: ", ok)

func _establish_camp_on_selected(zones: Array) -> void:
	if selected_index < 0 or selected_index >= zones.size():
		print("DEBUG: Establish Camp pressed but no zone selected — press 1-9 first")
		return
	var anchor: ZoneAnchor3D = zones[selected_index]
	if anchor.zone_node == null:
		return
	EventBus.ui.zone_selected.emit(anchor.zone_node)
	var api = ServiceLocator.get_management_service()
	if api == null:
		print("DEBUG: Establish Camp failed — ManagementAPI not available")
		return
	print("DEBUG: Keyboard Establish Camp on node=", anchor.zone_node.node_id)
	api.establish_camp(anchor.zone_node.node_id)

func _post_forager_on_selected(zones: Array) -> void:
	if selected_index < 0 or selected_index >= zones.size():
		print("DEBUG: Post Forager pressed but no zone selected — press 1-9 first")
		return
	var anchor: ZoneAnchor3D = zones[selected_index]
	if anchor.zone_node == null:
		return
	EventBus.ui.zone_selected.emit(anchor.zone_node)
	var api = ServiceLocator.get_management_service()
	if api == null:
		print("DEBUG: Post Forager failed — ManagementAPI not available")
		return
	var ok: bool = api.post_manual_job(anchor.zone_node.node_id, "forager", 2)
	print("DEBUG: Keyboard Post Forager result: ", ok)

func _is_key_just_pressed(key_code: int) -> bool:
	var currently_pressed: bool = Input.is_key_pressed(key_code)
	var was_pressed: bool = _prev_key_states.get(key_code, false)
	_prev_key_states[key_code] = currently_pressed
	return currently_pressed and not was_pressed