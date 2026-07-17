extends Area3D
class_name ZoneAnchor3D

@export var zone_node: ZoneNode

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var visual_mesh: MeshInstance3D = $VisualMesh

func _ready() -> void:
	# Register in group so ManagementModeController can toggle all anchors at once
	add_to_group("zone_anchors")

	if zone_node != null:
		var api = ServiceLocator.get_management_service()
		if api != null:
			api._world_nodes[zone_node.node_id] = zone_node

		zone_node.building_completed.connect(_on_building_completed)

	# Listen for global management mode changes
	EventBus.management_mode_changed.connect(_on_management_mode_changed)

	# Connect Area3D input event for click detection
	input_event.connect(_on_input_event)

	# Start in dormant state
	toggle_management_view(false)

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
			EventBus.zone_selected.emit(zone_node.node_id)

func _on_management_mode_changed(is_active: bool) -> void:
	toggle_management_view(is_active)

func _on_building_completed(node_id: int, building_id: String) -> void:
	EventBus.message_logged.emit("Building completed in node " + str(node_id) + ": " + building_id, "info")

	var path = "res://scenes/world/buildings/" + building_id + ".tscn"
	if ResourceLoader.exists(path):
		var scene = load(path)
		if scene:
			var instance = scene.instantiate()
			add_child(instance)

			# Arrange buildings in a circle around the node anchor
			var building_index = zone_node.buildings.size() - 1
			var angle = building_index * (2 * PI / 8.0) # support up to 8 buildings
			var radius = 6.0
			instance.position = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
