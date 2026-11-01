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
	EventBus.ui.debug("Keyboard selector found " + " " + str(zones.size()) + " " + " zones")
	if selected_index >= zones.size():
		selected_index = -1

func _process(_delta: float) -> void:
	if not management_active:
		return
	var bindings: KeyBindingSet = load("res://data/ui/keybindings.tres")
	if bindings == null:
		return
	var zones := _get_zones()
	# Number keys 1-9 select zone directly (no arrow/movement conflict)
	for i in range(1, 10):
		if zones.size() > i - 1 and _is_key_just_pressed(KEY_1 + i - 1):
			selected_index = i - 1
			_select_zone(zones)
	# Enter = open inspection on selected zone
	if Input.is_action_just_pressed("ui_accept"):
		if selected_index < 0:
			EventBus.ui.message_logged.emit("Select a zone first (press 1-9).", "warn")
		_select_zone(zones)
	# E = Establish Camp on selected zone (wilderness only)
	if _is_key_just_pressed(bindings.get_key("establish_camp")):
		_establish_camp_on_selected(zones)
	# B = trigger build on selected zone
	if _is_key_just_pressed(bindings.get_key("order_building")):
		_build_on_selected(zones)
	# F = post 2 forager jobs on selected zone (camp only)
	if _is_key_just_pressed(bindings.get_key("post_forager")):
		_post_job_on_selected(zones, "forager", 2)
	# G = post 1 woodcutter job on selected zone (camp only) — timber regrowth
	if _is_key_just_pressed(bindings.get_key("post_woodcutter")):
		_post_job_on_selected(zones, "woodcutter", 1)
	# C = cycle the blueprint selection in the inspection panel
	if _is_key_just_pressed(bindings.get_key("cycle_blueprint")):
		EventBus.ui.blueprint_cycle_requested.emit()

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
		EventBus.ui.debug("Selecting zone " + " " + str(selected_index) + " " + " node_id=" + " " + str(anchor.zone_node.node_id) + " " + " name=" + " " + str(anchor.zone_node.node_name))
		EventBus.ui.zone_selected.emit(anchor.zone_node)

func _build_on_selected(zones: Array) -> void:
	if selected_index < 0 or selected_index >= zones.size():
		EventBus.ui.message_logged.emit("Select a zone first (press 1-9).", "warn")
		EventBus.ui.debug("Build pressed but no zone selected — press 1-9 first")
		return
	var anchor: ZoneAnchor3D = zones[selected_index]
	if anchor.zone_node == null:
		return
	# Decoupled (#70): the panel applies its selected blueprint — the keyboard
	# never picks the blueprint itself.
	EventBus.ui.zone_selected.emit(anchor.zone_node)
	EventBus.ui.blueprint_order_requested.emit()
	EventBus.ui.debug("Keyboard Build request emitted (panel applies its selection)")

func _establish_camp_on_selected(zones: Array) -> void:
	if selected_index < 0 or selected_index >= zones.size():
		EventBus.ui.message_logged.emit("Select a zone first (press 1-9).", "warn")
		EventBus.ui.debug("Establish Camp pressed but no zone selected — press 1-9 first")
		return
	var anchor: ZoneAnchor3D = zones[selected_index]
	if anchor.zone_node == null:
		return
	EventBus.ui.zone_selected.emit(anchor.zone_node)
	var api = ServiceLocator.get_management_service()
	if api == null:
		EventBus.ui.debug("Establish Camp failed — ManagementAPI not available")
		return
	EventBus.ui.debug("Keyboard Establish Camp on node=" + " " + str(anchor.zone_node.node_id))
	api.establish_camp(anchor.zone_node.node_id)

func _post_job_on_selected(zones: Array, job_type: String, slots: int) -> void:
	if selected_index < 0 or selected_index >= zones.size():
		EventBus.ui.message_logged.emit("Select a zone first (press 1-9).", "warn")
		EventBus.ui.debug("Post " + " " + str(job_type) + " " + " pressed but no zone selected")
		return
	var anchor: ZoneAnchor3D = zones[selected_index]
	if anchor.zone_node == null:
		return
	EventBus.ui.zone_selected.emit(anchor.zone_node)
	var api = ServiceLocator.get_management_service()
	if api == null:
		EventBus.ui.message_logged.emit("Management service unavailable.", "warn")
		return
	var ok: bool = api.post_manual_job(anchor.zone_node.node_id, job_type, slots)
	EventBus.ui.debug("Keyboard Post " + " " + str(job_type) + " " + " result: " + " " + str(ok))

func _is_key_just_pressed(key_code: int) -> bool:
	var currently_pressed: bool = Input.is_key_pressed(key_code)
	var was_pressed: bool = _prev_key_states.get(key_code, false)
	_prev_key_states[key_code] = currently_pressed
	return currently_pressed and not was_pressed