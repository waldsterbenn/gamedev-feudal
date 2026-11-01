extends Node
class_name ManagementAPI

signal settlement_tier_changed(node_id: int, new_tier_string: String)
signal construction_failed_no_resources(node_id: int, building_id: String)
signal operation_failed(reason: String)

# Reference to the coordinator
@onready var game_coordinator: Node = get_parent()

# Registered populants (character_id: int -> ManagementPopulantComponent)
var _registered_populants: Dictionary = {}

func _enter_tree() -> void:
	ServiceLocator.register_management_service(self)

## Wire a zone's starving + famine signals to UI toasts. Done at
## establish_camp — food pressure only matters once a camp exists. Kept in
## the API layer (Node): ZoneNode stays signal-only and compiles standalone
## in --script mode (#85).
func _wire_starving_toast(node: ZoneNode) -> void:
	if not node.populants_starving.is_connected(_on_populants_starving):
		node.populants_starving.connect(_on_populants_starving)
	if not node.zone_famine.is_connected(_on_zone_famine):
		node.zone_famine.connect(_on_zone_famine)

func _on_populants_starving(node_id: int, starving_count: int) -> void:
	var node: ZoneNode = _get_world_nodes().get(node_id)
	var zone_name: String = node.node_name if node else "Zone %d" % node_id
	EventBus.ui.message_logged.emit("⚠ %d starving at %s — assign foragers!" % [starving_count, zone_name], "warn")

func _on_zone_famine(node_id: int, off_the_land_count: int) -> void:
	var node: ZoneNode = _get_world_nodes().get(node_id)
	var zone_name: String = node.node_name if node else "Zone %d" % node_id
	EventBus.ui.message_logged.emit("🌾 Famine at %s — %d living off the land, workplaces unmanned." % [zone_name, off_the_land_count], "warn")

func register_populant_component(comp: ManagementPopulantComponent) -> void:
	_registered_populants[comp.character_id] = comp

## Moves an existing registration to a new key after a late character_id change.
func rekey_populant_registration(old_id: int, comp: ManagementPopulantComponent) -> void:
	if old_id == comp.character_id:
		return
	_registered_populants.erase(old_id)
	_registered_populants[comp.character_id] = comp

func unregister_populant_component(character_id: int) -> void:
	_registered_populants.erase(character_id)

func _get_npc_management_populant_component(character_id: int) -> ManagementPopulantComponent:
	return _registered_populants.get(character_id, null)

func _get_world_nodes() -> Dictionary:
	if game_coordinator and game_coordinator.game_context:
		return game_coordinator.game_context.world_nodes
	return {}

func _remove_worker_from_node_data(character_id: int, node_id: int) -> void:
	var nodes = _get_world_nodes()
	var node: ZoneNode = nodes.get(node_id)
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
	var nodes = _get_world_nodes()
	var node: ZoneNode = nodes.get(node_id)
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
	var nodes = _get_world_nodes()
	if nodes.has(node_id):
		return nodes[node_id].canopy_density
	return 0.0

## API Query: Returns a basic data snapshot dictionary for UI framework parsing
func get_node_inspection_data(node_id: int) -> Dictionary:
	var nodes = _get_world_nodes()
	if not nodes.has(node_id):
		return {}
		
	var node: ZoneNode = nodes[node_id]
	return {
		"node_id": node.node_id,
		"node_name": node.node_name,
		"tier_name": ZoneNode.SettlementTier.keys()[node.current_tier],
		"canopy": node.canopy_density,
		"timber_fertility": node.fertilities.get("Timber", 0.0),
		"berry_stock": node.stockpile.get("Berries", 0),
		"mushroom_stock": node.stockpile.get("Mushrooms", 0),
		"timber_stock": node.stockpile.get("Timber", 0),
		"is_camp_creatable": (node.current_tier == ZoneNode.SettlementTier.WILDERNESS),
		"buildings": node.buildings.map(func(b) -> Dictionary:
			return {
				"name": b.blueprint.display_name,
				"progress": b.construction_progress,
				"total": b.blueprint.total_work_required,
				"completed": b.is_completed,
			}),
		"job_assignments": {
			"forager": {
				"assigned": node._get_assigned_count("forager"),
				"target": node.manual_job_postings.get("forager", 0),
			},
			"woodcutter": {
				"assigned": node._get_assigned_count("woodcutter"),
				"target": node.manual_job_postings.get("woodcutter", 0),
			},
			"builder": {
				"assigned": node._get_assigned_count("builder"),
			},
			"foreman": {
				"assigned": node._get_assigned_count("foreman"),
				"target": node.manual_job_postings.get("foreman", 0),
			},
		},
		"job_caps": {
			"forager": node._building_capacity("forager"),
			"woodcutter": node._building_capacity("woodcutter"),
			"foreman": node._building_capacity("foreman"),
		},
		"starving": node._last_starving_count,
		"famine": node._get_assigned_count("off_the_land"),
	}

## API Query: Returns the number of local workers assigned to a node
func get_node_worker_count(node_id: int) -> int:
	var nodes = _get_world_nodes()
	var node: ZoneNode = nodes.get(node_id)
	return node.local_workers.size() if node else 0

## Executed when the player activates the 'Establish Camp' UI command
func establish_camp(node_id: int, owner_id: String = "player") -> void:
	var nodes = _get_world_nodes()
	var node: ZoneNode = nodes.get(node_id)
	if not node or node.current_tier != ZoneNode.SettlementTier.WILDERNESS:
		operation_failed.emit("Invalid or already settled node.")
		EventBus.ui.message_logged.emit("Cannot establish camp — already settled.", "warn")
		return

	node.current_tier = ZoneNode.SettlementTier.CAMP

	var tier_name = ZoneNode.SettlementTier.keys()[node.current_tier]
	settlement_tier_changed.emit(node_id, tier_name)
	EventBus.ui.message_logged.emit("Camp established at %s." % node.node_name, "info")
	_wire_starving_toast(node)
	_auto_queue_tent(node)

## Auto-queues a Tent on camp establishment (#85): the camp needs housing
## immediately; the tent builds through the normal #70 queue (shortfall ->
## builders gather -> resume). Skipped if a tent is already queued/completed.
func _auto_queue_tent(node: ZoneNode) -> void:
	for building in node.buildings:
		if building.blueprint.building_id == "tent":
			return
	var tent_bp: BuildingData = load("res://data/blueprints/tent.tres")
	order_building(node.node_id, tent_bp)

## Housing capacity: sum over COMPLETED housing buildings (#85). A camp
## before its tent completes has 0 capacity — but residents already placed
## by the world initializer are never evicted.
func get_housing_capacity(node_id: int) -> int:
	var nodes = _get_world_nodes()
	var node: ZoneNode = nodes.get(node_id)
	if not node:
		return 0
	var capacity: int = 0
	for building in node.buildings:
		if building.is_completed and building.blueprint.housing_capacity > 0:
			capacity += building.blueprint.housing_capacity
	return capacity

## Executed when the player issues a build blueprint command
func order_building(node_id: int, blueprint: BuildingData) -> bool:
	var nodes = _get_world_nodes()
	var node: ZoneNode = nodes.get(node_id)
	if not node:
		return false
		
	# Slice rule (#70): orders are allowed ANYTIME. Whatever is affordable is
	# allocated now; the shortfall stalls construction while builders gather.
	var paid := {}
	for resource_name in blueprint.build_cost:
		var cost: int = blueprint.build_cost[resource_name]
		var available: int = node.stockpile.get(resource_name, 0)
		var used: int = min(cost, available)
		paid[resource_name] = used
		if used > 0:
			node.stockpile[resource_name] = available - used
			node.allocated_construction_resources[resource_name] = node.allocated_construction_resources.get(resource_name, 0) + used
		
	var new_building = BuildingInstance.new()
	new_building.blueprint = blueprint
	new_building.is_completed = false
	new_building.construction_progress = 0.0
	
	node.buildings.append(new_building)
	# World visual spawn (#70): the zone anchor instantiates the blueprint scene
	node.building_ordered.emit(node_id, new_building)
	
	var missing_parts: PackedStringArray = []
	for resource_name in blueprint.build_cost:
		var missing: int = blueprint.build_cost[resource_name] - paid[resource_name]
		if missing > 0:
			missing_parts.append("%d %s" % [missing, resource_name])
	if missing_parts.is_empty():
		EventBus.ui.message_logged.emit("%s construction started (work %d)." % [blueprint.display_name, blueprint.total_work_required], "info")
	else:
		EventBus.ui.message_logged.emit("%s construction ordered — missing %s; builders will gather it." % [blueprint.display_name, ", ".join(missing_parts)], "warn")
	return true

## Adjusts the player-controlled desired count for a production job (#73/#88).
## The job's capacity comes from COMPLETED buildings: no building = no slots
## (refused with a hint which building to build); increases past capacity
## refuse with the same hint. manual_job_postings persist as preference but
## allocation clamps them to building capacity.
func adjust_job_target(node_id: int, job_type: String, delta: int) -> bool:
	var nodes = _get_world_nodes()
	var node: ZoneNode = nodes.get(node_id)
	if not node:
		return false
	var capacity: int = node._building_capacity(job_type)
	var current: int = node.manual_job_postings.get(job_type, 0)
	var desired: int = current + delta
	if desired < 0:
		desired = 0
	if delta > 0 and desired > capacity:
		if capacity == 0:
			EventBus.ui.message_logged.emit("No %s slots at %s — build the %s first." % [job_type, node.node_name, _building_name_for(job_type)], "warn")
		else:
			EventBus.ui.message_logged.emit("All %d %s slots filled at %s — build another %s." % [capacity, job_type, node.node_name, _building_name_for(job_type)], "warn")
		return false
	var other_targets: int = 0
	for jt in node.manual_job_postings:
		if jt != job_type:
			other_targets += node.manual_job_postings[jt]
	var workers: int = node.local_workers.size()
	if delta > 0 and desired > workers - other_targets:
		EventBus.ui.message_logged.emit("Not enough free workers at %s (%d total, %d on other tasks)." % [node.node_name, workers, other_targets], "warn")
		return false
	if desired == current:
		if delta < 0:
			EventBus.ui.message_logged.emit("No %s jobs to remove at %s." % [job_type.capitalize(), node.node_name], "warn")
		return false
	node.manual_job_postings[job_type] = desired
	EventBus.ui.message_logged.emit("%s workers: %d -> %d at %s." % [job_type.capitalize(), current, desired, node.node_name], "info")
	return true

## Display name of the building that provides a job category's slots (#88).
func _building_name_for(job_type: String) -> String:
	match job_type:
		"forager": return "Forager Hut"
		"woodcutter": return "Lumber Camp"
		"foreman": return "Foreman's Tent"
	return job_type.capitalize()

## Executed when the player posts a manual job opening from the UI —
## delegates to the capped adjust_job_target (#70)
func post_manual_job(node_id: int, job_type: String, slots: int = 2) -> bool:
	var nodes = _get_world_nodes()
	var node: ZoneNode = nodes.get(node_id)
	if not node:
		operation_failed.emit("Unknown node.")
		return false
	if node.current_tier == ZoneNode.SettlementTier.WILDERNESS:
		operation_failed.emit("Cannot post jobs at a wilderness zone — establish a camp first.")
		EventBus.ui.message_logged.emit("Post jobs fails — establish a camp first.", "warn")
		return false
	return adjust_job_target(node_id, job_type, slots)

## Binds an NPC's management component profile to a specific Lord faction
func recruit_populant_to_faction(character_id: int, lord_id: String = "player") -> void:
	var populant_comp = _get_npc_management_populant_component(character_id)
	if populant_comp:
		populant_comp.serving_lord_id = lord_id

## Assigns a faction-aligned Populant to live and work at a target ZoneNode
func assign_populant_to_node(character_id: int, target_node_id: int) -> bool:
	var nodes = _get_world_nodes()
	if not nodes.has(target_node_id):
		return false
		
	var node: ZoneNode = nodes[target_node_id]
	var populant_comp = _get_npc_management_populant_component(character_id)
	
	# Housing cap (#85): a zone cannot hold more residents than its completed
	# housing (tents) support. Enforced only once housing EXISTS — world-init
	# placements happen before any tent completes and always pass.
	var residents: int = node.local_workers.size()
	var capacity: int = get_housing_capacity(target_node_id)
	if capacity > 0 and residents >= capacity and (populant_comp == null or populant_comp.assigned_node_id != target_node_id):
		EventBus.ui.message_logged.emit("%s is full — build another Tent (%d/%d residents)." % [node.node_name, residents, capacity], "warn")
		return false
	
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

## Finds the physical NPC in the scene tree and switches it to the AssignedWork state
func _notify_assignment(character_id: int) -> void:
	var comp = _get_npc_management_populant_component(character_id)
	if not comp:
		return
	var actor = comp.get_parent()
	if actor and actor.has_method("assign_to_work"):
		actor.assign_to_work()
