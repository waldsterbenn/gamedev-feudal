extends Resource
class_name ZoneNode

signal building_completed(node_id: int, building_id: String)
signal populants_starving(node_id: int, starving_count: int)

enum SettlementTier { WILDERNESS, CAMP, FARM, MANOR, VILLAGE, TOWN }

@export var node_id: int
@export var node_name: String
@export var current_tier: SettlementTier = SettlementTier.WILDERNESS

# Environmental Dynamics & Base Fertilities
@export var canopy_density: float = 1.0
@export var fertilities: Dictionary = {
	"Timber": 0.7, 
	"Cereals": 0.5, 
	"Berries": 0.4,
	"Mushrooms": 0.3
}

# Inventories & Storage limits
@export var stockpile: Dictionary = {}
@export var allocated_construction_resources: Dictionary = {}
@export var max_storage_capacity: int = 200

# Infrastructure & Workers
@export var buildings: Array[BuildingInstance] = []
@export var local_workers: Array[WorkerData] = []
@export var manual_job_postings: Dictionary = {}

# Active assignments populated during tick matching
var _assigned_workers_by_job: Dictionary = {}

## Helper: Checks if the node has enough available resources
func has_available_resources(requirements: Dictionary) -> bool:
	for resource_name in requirements:
		var required_amount: int = requirements[resource_name]
		var available_amount: int = stockpile.get(resource_name, 0)
		if available_amount < required_amount:
			return false
	return true

## System Master Function executing local economic updates
func process_management_tick() -> void:
	if current_tier == SettlementTier.WILDERNESS:
		return
		
	_resolve_workforce_allocation()  # Step 1: Dynamic Qualification Matching
	_deduct_sustenance_inventories() # Step 2: Food Consumption Check
	_process_construction_progress() # Step 3: Construction Progress Processing
	_execute_production_and_labor()  # Step 4: Environmental Extraction Mechanics
	_enforce_storage_caps()          # Step 5: Warehouse Auditing

## Gathers open jobs, adding 3 builder slots for each incomplete building instance
func get_total_job_slots() -> Dictionary:
	var slots = manual_job_postings.duplicate()
	for building in buildings:
		if not building.is_completed:
			slots["builder"] = slots.get("builder", 0) + 3
		else:
			var job = building.blueprint.job_type
			if job != "":
				slots[job] = slots.get(job, 0) + building.blueprint.max_jobs
	return slots

func _get_assigned_count(job_type: String) -> int:
	if _assigned_workers_by_job.has(job_type):
		return _assigned_workers_by_job[job_type].size()
	return 0

## Resolves workforce allocation by matching local workers to available jobs based on priority
func _resolve_workforce_allocation() -> void:
	_assigned_workers_by_job.clear()
	for building in buildings:
		building.assigned_worker_ids.clear()
		
	var unassigned_workers = local_workers.duplicate()
	var slots = get_total_job_slots()
	
	for job_type in JobPriorities.HIERARCHY:
		var open_slots = slots.get(job_type, 0)
		if open_slots <= 0:
			continue
			
		var assigned_ids: Array[int] = []
		while open_slots > 0 and not unassigned_workers.is_empty():
			var worker = unassigned_workers.pop_front()
			assigned_ids.append(worker.character_id)
			open_slots -= 1
			
			if job_type != "builder":
				for building in buildings:
					if building.is_completed and building.blueprint.job_type == job_type:
						if building.assigned_worker_ids.size() < building.blueprint.max_jobs:
							building.assigned_worker_ids.append(worker.character_id)
							break
							
		_assigned_workers_by_job[job_type] = assigned_ids

## Processes daily food consumption across all checked residents
func _deduct_sustenance_inventories() -> void:
	var hungry_mouths: int = local_workers.size()
	if hungry_mouths <= 0:
		return
		
	for food_type in DietPriorities.CONSUMPTION_ORDER:
		if hungry_mouths <= 0:
			break
		var available_food: int = stockpile.get(food_type, 0)
		if available_food > 0:
			var food_taken: int = min(hungry_mouths, available_food)
			stockpile[food_type] -= food_taken
			hungry_mouths -= food_taken

	if hungry_mouths > 0:
		populants_starving.emit(node_id, hungry_mouths)

## Spends labor points on active construction jobs sequentially
func _process_construction_progress() -> void:
	var active_builders = _get_assigned_count("builder")
	if active_builders <= 0:
		return
		
	var total_labor_pool: float = active_builders * 10.0 # 10 Labor power per worker
	
	for building in buildings:
		if not building.is_completed:
			building.construction_progress += total_labor_pool
			total_labor_pool = 0.0 
			
			if building.construction_progress >= building.blueprint.total_work_required:
				building.is_completed = true
				building.construction_progress = building.blueprint.total_work_required
				
				# Flush allocated material counters out of the hold
				for resource_name in building.blueprint.build_cost:
					var cost: int = building.blueprint.build_cost[resource_name]
					allocated_construction_resources[resource_name] = max(0, allocated_construction_resources.get(resource_name, 0) - cost)
					
				building_completed.emit(node_id, building.blueprint.building_id)
			break

## Handles raw material yields and coupled environmental degradation formulas
func _execute_production_and_labor() -> void:
	var foragers = _get_assigned_count("forager")
	var woodcutters = _get_assigned_count("woodcutter")
	
	# Timber Extraction Math
	if woodcutters > 0 and canopy_density > 0.01:
		var timber_yield = max(1, roundi(woodcutters * 4 * fertilities.get("Timber", 0.0) * canopy_density))
		stockpile["Timber"] = stockpile.get("Timber", 0) + timber_yield
		canopy_density = max(0.0, canopy_density - (timber_yield * 0.002))
		
	# Linked Ecosystem Foraging Math
	if foragers > 0:
		var berry_yield = roundi(foragers * 5 * fertilities.get("Berries", 0.0))
		# Shifting mushroom yields based directly on how badly the canopy is clear-cut
		var mushroom_yield = roundi(foragers * 3 * fertilities.get("Mushrooms", 0.0) * canopy_density)
		
		stockpile["Berries"] = stockpile.get("Berries", 0) + berry_yield
		stockpile["Mushrooms"] = stockpile.get("Mushrooms", 0) + mushroom_yield

## Audits storage stockpile and trims excess to stay below capacity limits
func _enforce_storage_caps() -> void:
	var total_items: int = 0
	for resource in stockpile:
		total_items += stockpile[resource]
		
	if total_items > max_storage_capacity:
		var excess: int = total_items - max_storage_capacity
		# TODO(event-system): surface this via the replacement for legacy EventBus.message_logged
		push_warning("Node " + str(node_id) + " stockpile exceeded storage capacity! Discarding " + str(excess) + " excess items.")
		
		for resource in stockpile:
			if excess <= 0:
				break
			var amount = stockpile[resource]
			if amount > 0:
				var discard = min(excess, amount)
				stockpile[resource] -= discard
				excess -= discard
