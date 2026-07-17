extends Node

signal settlement_tier_changed(node_id: int, new_tier_string: String)
signal construction_failed_no_resources(node_id: int, building_id: String)
signal operation_failed(reason: String)

# Internal reference to the complete array of simulated world data resources
var _world_nodes: Dictionary = {} 

# Registered populants (character_id: int -> ManagementPopulantComponent)
var _registered_populants: Dictionary = {}

func _ready() -> void:
	ServiceLocator.register_management_service(self)
	# TODO(event-system): subscribe to the day tick via the replacement for legacy EventBus.day_changed

func register_populant_component(comp: ManagementPopulantComponent) -> void:
	_registered_populants[comp.character_id] = comp

func unregister_populant_component(character_id: int) -> void:
	_registered_populants.erase(character_id)

func _get_npc_management_populant_component(character_id: int) -> ManagementPopulantComponent:
	return _registered_populants.get(character_id, null)

func _remove_worker_from_node_data(character_id: int, node_id: int) -> void:
	var node: ZoneNode = _world_nodes.get(node_id)
	if not node:
		return
	for i in range(node.local_workers.size() - 1, -1, -1):
		if node.local_workers[i].character_id == character_id:
			node.local_workers.remove_at(i)

## API Query: Returns the macro-assignment for a given agent
func get_character_assignment(char_id: int) -> Dictionary:
	var populant_comp = _get_npc_management_populant_component(char_id)
	if not populant_comp or populant_comp.assigned_node_id == -1:
		return {}
		
	var node_id = populant_comp.assigned_node_id
	var node: ZoneNode = _world_nodes.get(node_id)
	if not node:
		return {}
		
	var job_type: String = "idle"
	for building in node.buildings:
		if building.assigned_worker_ids.has(char_id):
			job_type = building.blueprint.job_type
			break
			
	var pos: Vector3 = Vector3.ZERO
	if populant_comp.current_3d_workplace_target != null:
		pos = populant_comp.current_3d_workplace_target.global_position
	else:
		var actor = populant_comp.get_parent()
		if actor is Node3D:
			pos = actor.global_position
			
	return {
		"node_id": node_id,
		"job_type": job_type,
		"work_target_position": pos
	}

## API Query: Allows environmental rendering engines to update Terrain3D foliage elements
func get_node_canopy_density(node_id: int) -> float:
	if _world_nodes.has(node_id):
		return _world_nodes[node_id].canopy_density
	return 0.0

## API Query: Returns a basic data snapshot dictionary for UI framework parsing
func get_node_inspection_data(node_id: int) -> Dictionary:
	if not _world_nodes.has(node_id):
		return {}
		
	var node: ZoneNode = _world_nodes[node_id]
	return {
		"node_id": node.node_id,
		"node_name": node.node_name,
		"tier_name": ZoneNode.SettlementTier.keys()[node.current_tier],
		"canopy": node.canopy_density,
		"timber_fertility": node.fertilities.get("Timber", 0.0),
		"berry_stock": node.stockpile.get("Berries", 0),
		"mushroom_stock": node.stockpile.get("Mushrooms", 0),
		"timber_stock": node.stockpile.get("Timber", 0),
		"is_camp_creatable": (node.current_tier == ZoneNode.SettlementTier.WILDERNESS)
	}

## Executed when the player activates the 'Establish Camp' UI command
func establish_camp(node_id: int, owner_id: String = "player") -> void:
	var node: ZoneNode = _world_nodes.get(node_id)
	if not node or node.current_tier != ZoneNode.SettlementTier.WILDERNESS:
		operation_failed.emit("Invalid or already settled node.")
		return
		
	node.current_tier = ZoneNode.SettlementTier.CAMP
	
	var tier_name = ZoneNode.SettlementTier.keys()[node.current_tier]
	settlement_tier_changed.emit(node_id, tier_name)

## Executed when the player issues a build blueprint command
func order_building(node_id: int, blueprint: BuildingData) -> bool:
	var node: ZoneNode = _world_nodes.get(node_id)
	if not node:
		return false
		
	if not node.has_available_resources(blueprint.build_cost):
		construction_failed_no_resources.emit(node_id, blueprint.building_id)
		return false
		
	for resource_name in blueprint.build_cost:
		var cost: int = blueprint.build_cost[resource_name]
		node.stockpile[resource_name] -= cost
		node.allocated_construction_resources[resource_name] = node.allocated_construction_resources.get(resource_name, 0) + cost
		
	var new_building = BuildingInstance.new()
	new_building.blueprint = blueprint
	new_building.is_completed = false
	new_building.construction_progress = 0.0
	
	node.buildings.append(new_building)
	return true

## Binds an NPC's management component profile to a specific Lord faction
func recruit_populant_to_faction(character_id: int, lord_id: String = "player") -> void:
	var populant_comp = _get_npc_management_populant_component(character_id)
	if populant_comp:
		populant_comp.serving_lord_id = lord_id

## Assigns a faction-aligned Populant to live and work at a target ZoneNode
func assign_populant_to_node(character_id: int, target_node_id: int) -> bool:
	if not _world_nodes.has(target_node_id):
		return false
		
	var node: ZoneNode = _world_nodes[target_node_id]
	var populant_comp = _get_npc_management_populant_component(character_id)
	
	if not populant_comp or populant_comp.serving_lord_id == "none":
		return false
		
	if populant_comp.assigned_node_id != -1:
		_remove_worker_from_node_data(character_id, populant_comp.assigned_node_id)
		
	populant_comp.assigned_node_id = target_node_id
	
	var new_worker_link = WorkerData.new()
	new_worker_link.character_id = character_id
	new_worker_link.qualification = populant_comp.qualification_profile
	node.local_workers.append(new_worker_link)
	
	# Notify the physical NPC actor to enter the AssignedWork state
	_notify_assignment(character_id)
	
	return true

func _on_day_changed(new_day: int) -> void:
	for node_id in _world_nodes:
		var node: ZoneNode = _world_nodes[node_id]
		node.process_management_tick()

## Finds the physical NPC in the scene tree and switches it to the AssignedWork state
func _notify_assignment(character_id: int) -> void:
	var comp = _get_npc_management_populant_component(character_id)
	if not comp:
		return
	var actor = comp.get_parent()
	if actor and actor.has_method("assign_to_work"):
		actor.assign_to_work()
