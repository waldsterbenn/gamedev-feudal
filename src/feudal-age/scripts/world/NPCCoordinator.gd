class_name NPCCoordinator
extends Node

@export var npc_prefab: PackedScene
@export var container_path: NodePath

var _container: Node
var _tracked_npcs: Dictionary = {} # int (id) -> NPC
var _next_id: int = 1

func _ready() -> void:
	if container_path.is_empty():
		push_error("NPCCoordinator: container_path is not set.")
		return
	_container = get_node(container_path)

## Instantiates an NPC prefab, syncs IDs across contexts, attaches to container, and returns instance.
func create_npc(global_transform: Transform3D = Transform3D.IDENTITY) -> NPC:
	if not npc_prefab:
		push_error("NPCCoordinator: npc_prefab is not assigned in the Inspector.")
		return null
	if not _container:
		push_error("NPCCoordinator: container node is invalid.")
		return null

	var npc_instance: NPC = npc_prefab.instantiate() as NPC
	if not npc_instance:
		push_error("NPCCoordinator: Failed to instantiate NPC prefab as NPC class.")
		return null

	# Assign stable Coordinator ID
	var assigned_id: int = _next_id
	_next_id += 1
	npc_instance.id = assigned_id

	# Single Source of Truth: Sync Management Component ID prior to _ready() execution
	var management_comp = npc_instance.get_node_or_null("ManagementPopulantComponent") as ManagementPopulantComponent
	if management_comp:
		management_comp.character_id = assigned_id

	_tracked_npcs[assigned_id] = npc_instance

	# Adjust height based on terrain
	var terrain_service = ServiceLocator.get_terrain_service()
	if terrain_service:
		var height: float = terrain_service.get_height(global_transform.origin)
		if not is_nan(height):
			global_transform.origin.y = height

	_container.add_child(npc_instance)
	npc_instance.global_transform = global_transform

	return npc_instance

## Destroys and frees an NPC instance by its Coordinator ID.
func destroy_npc(id: int) -> bool:
	if not _tracked_npcs.has(id):
		push_warning("NPCCoordinator: Attempted to destroy un-tracked NPC ID: %d" % id)
		return false

	var npc_instance: NPC = _tracked_npcs[id]
	_tracked_npcs.erase(id)

	if is_instance_valid(npc_instance):
		npc_instance.queue_free()

	return true

## Returns a tracked NPC by ID, or null if not found.
func get_npc(id: int) -> NPC:
	return _tracked_npcs.get(id, null) as NPC

## Returns an Array of all currently tracked NPC instances.
func get_all_npcs() -> Array[NPC]:
	var result: Array[NPC] = []
	for npc in _tracked_npcs.values():
		if is_instance_valid(npc):
			result.append(npc)
	return result

## Finds nearest NPC to a given world position within max_distance in meters.
func find_nearest_npc(global_position: Vector3, max_distance: float = INF) -> NPC:
	var nearest: NPC = null
	var min_distance_sq: float = max_distance * max_distance

	for npc in _tracked_npcs.values():
		if not is_instance_valid(npc):
			continue
		var dist_sq: float = global_position.distance_squared_to(npc.global_position)
		if dist_sq < min_distance_sq:
			min_distance_sq = dist_sq
			nearest = npc

	return nearest
