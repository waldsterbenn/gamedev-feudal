extends Node
class_name ZoneCoordinator

@export var zone_prefab: PackedScene
@export var container_path: NodePath

@onready var container: Node3D = get_node(container_path)

# Dictionary tracking active anchors: coordinator_id -> ZoneAnchor3D
var _active_anchors: Dictionary = {}

func create_zone_anchor(id: int, global_pos: Vector3) -> ZoneAnchor3D:
	if _active_anchors.has(id):
		push_warning("Zone anchor with ID %d already exists." % id)
		return _active_anchors[id]
		
	var instance = zone_prefab.instantiate() as ZoneAnchor3D
	instance.coordinator_id = id
	container.add_child(instance)
	instance.global_position = global_pos
	
	_active_anchors[id] = instance
	return instance

func destroy_zone_anchor(id: int) -> void:
	if _active_anchors.has(id):
		var node = _active_anchors[id]
		_active_anchors.erase(id)
		node.queue_free()

func get_zone_anchor(id: int) -> ZoneAnchor3D:
	return _active_anchors.get(id, null)

func get_all_zone_anchors() -> Array[ZoneAnchor3D]:
	var result: Array[ZoneAnchor3D] = []
	for anchor in _active_anchors.values():
		result.append(anchor)
	return result
