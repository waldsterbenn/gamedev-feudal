extends Area3D
class_name ZoneAnchor3D

@export var zone_node: ZoneNode

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var visual_mesh: MeshInstance3D = $VisualMesh

var coordinator_id: int = -1

func _ready() -> void:
	# Register in group so ManagementModeController can toggle all anchors at once
	add_to_group("zone_anchors")

	EventBus.ui.management_mode_changed.connect(_on_management_mode_changed)

	# Connect Area3D input event for click detection
	input_event.connect(_on_input_event)

	# Start in dormant state
	toggle_management_view(false)

func initialize(node: ZoneNode) -> void:
	zone_node = node
	
	# Register this zone into the shared FiefStateResource context
	var api = ServiceLocator.get_management_service()
	if api != null and api.game_coordinator != null:
		var ctx = api.game_coordinator.game_context
		if ctx != null:
			ctx.world_nodes[zone_node.node_id] = zone_node
			
	if not zone_node.building_completed.is_connected(_on_building_completed):
		zone_node.building_completed.connect(_on_building_completed)

	if not zone_node.building_ordered.is_connected(_on_building_ordered):
		zone_node.building_ordered.connect(_on_building_ordered)

func toggle_management_view(is_active: bool) -> void:
	if visual_mesh:
		visual_mesh.visible = is_active

	if is_active:
		collision_layer = 8 # Layer 4 (interaction)
		collision_mask = 0
	else:
		collision_layer = 0
		collision_mask = 0

## Handles mouse clicks on the anchor when management mode is active
func _on_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if zone_node != null:
			EventBus.ui.zone_selected.emit(zone_node)

func _on_management_mode_changed(is_active: bool) -> void:
	toggle_management_view(is_active)

func _on_building_ordered(_node_id: int, building: BuildingInstance) -> void:
	_spawn_building_visual(building)

func _on_building_completed(node_id: int, building_id: String) -> void:
	EventBus.ui.message_logged.emit("Building completed in node %d: %s" % [node_id, building_id], "info")
	# Visual already spawned at order time (#70) — no second instance

## Instantiates the blueprint's primitive scene in-world at order time (#70)
func _spawn_building_visual(building: BuildingInstance) -> void:
	var path: String = building.blueprint.visual_scene_path
	if path == "" or not ResourceLoader.exists(path):
		return
	var scene = load(path)
	if scene == null:
		return
	var instance = scene.instantiate()
	add_child(instance)

	# Arrange buildings in a circle around the node anchor
	var building_index: int = zone_node.buildings.find(building)
	if building_index == -1:
		building_index = zone_node.buildings.size() - 1
	var angle: float = building_index * (2 * PI / 8.0) # support up to 8 buildings
	var radius: float = 6.0
	instance.position = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
