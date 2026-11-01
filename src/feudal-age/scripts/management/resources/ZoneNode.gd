extends Resource
class_name ZoneNode

signal building_completed(node_id: int, building_id: String)
signal building_ordered(node_id: int, building: BuildingInstance)
signal populants_starving(node_id: int, starving_count: int)

const FOREMAN_BONUS: float = 0.25  # per assigned foreman, max_jobs=1 caps it (#85)

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
## Starving residents from the most recent sustenance tick (UI reads; #85)
var _last_starving_count: int = 0

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

## Gathers open jobs: ONLY the player-controlled targets (#73). Completed
## buildings enable job types but never auto-grab workers — the player
## decides how many workers work each job via the modifier keys / panel.
func get_total_job_slots() -> Dictionary:
	return manual_job_postings.duplicate()

func _get_assigned_count(job_type: String) -> int:
	if _assigned_workers_by_job.has(job_type):
		return _assigned_workers_by_job[job_type].size()
	return 0

## Resolves workforce allocation (#70 model):
## 1) Targeted production jobs (food first, then raw extraction) — the
##    player-controlled counts (manual_job_postings + completed building slots).
## 2) Every remaining free worker is a builder — ALWAYS, not just while
##    construction runs (playtest 2026-11-01: a fresh camp holds 2 peasants
##    and they must tally as 2 builders from the start).
## 3) If queued construction still lacks materials, the builders are
##    temporarily reassigned as woodcutters to gather the shortfall first.
func _resolve_workforce_allocation() -> void:
	_assigned_workers_by_job.clear()
	for building in buildings:
		building.assigned_worker_ids.clear()
		
	var unassigned_workers = local_workers.duplicate()
	var slots = get_total_job_slots()
	
	for job_type in ["forager", "woodcutter"]:
		var open_slots = slots.get(job_type, 0)
		var assigned_ids: Array[int] = []
		while open_slots > 0 and not unassigned_workers.is_empty():
			var worker = unassigned_workers.pop_front()
			assigned_ids.append(worker.character_id)
			open_slots -= 1
			
			for building in buildings:
				if building.is_completed and building.blueprint.job_type == job_type:
					if building.assigned_worker_ids.size() < building.blueprint.max_jobs:
						building.assigned_worker_ids.append(worker.character_id)
						break
					
		_assigned_workers_by_job[job_type] = assigned_ids
	
	# Foreman is a per-building assignee too (player posts targets; #85 v1)
	var foreman_slots: int = slots.get("foreman", 0)
	var foreman_ids: Array[int] = []
	while foreman_slots > 0 and not unassigned_workers.is_empty():
		var worker = unassigned_workers.pop_front()
		foreman_ids.append(worker.character_id)
		foreman_slots -= 1
		for building in buildings:
			if building.is_completed and building.blueprint.job_type == "foreman":
				if building.assigned_worker_ids.size() < building.blueprint.max_jobs:
					building.assigned_worker_ids.append(worker.character_id)
					break
	_assigned_workers_by_job["foreman"] = foreman_ids
	
	var free_ids: Array[int] = []
	while not unassigned_workers.is_empty():
		free_ids.append(unassigned_workers.pop_front().character_id)
	
	if _has_incomplete_building() and _construction_shortfall() > 0:
		# Temp reassignment: all free workers gather Timber until covered.
		var gatherers: Array[int] = _assigned_workers_by_job.get("woodcutter", [])
		gatherers.append_array(free_ids)
		_assigned_workers_by_job["woodcutter"] = gatherers
	else:
		_assigned_workers_by_job["builder"] = free_ids

func _has_incomplete_building() -> bool:
	for building in buildings:
		if not building.is_completed:
			return true
	return false

## Total missing materials across queued construction. Resources are assigned
## to buildings sequentially (matching the completion flush), so a large
## zone-level allocation still leaves later buildings short.
func _construction_shortfall() -> int:
	var shortfall := 0
	for resource_name in allocated_construction_resources.keys():
		var available: int = allocated_construction_resources[resource_name]
		for building in buildings:
			if building.is_completed:
				continue
			var cost: int = building.blueprint.build_cost.get(resource_name, 0)
			if available >= cost:
				available -= cost
			else:
				shortfall += cost - available
				available = 0
	return shortfall

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
		_last_starving_count = hungry_mouths
		populants_starving.emit(node_id, hungry_mouths)
	else:
		_last_starving_count = 0

## Spends labor points on active construction jobs sequentially
func _process_construction_progress() -> void:
	var active_builders = _get_assigned_count("builder")
	if active_builders <= 0:
		return
	
	# Materials not fully covered yet — builders are gathering this tick (#70)
	if _construction_shortfall() > 0:
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
	var caps: Dictionary = _zone_storage_caps()
	
	# Timber Extraction Math — yield first refills any construction shortfall
	# (builders gathering materials), the surplus goes to the stockpile (#70).
	# Halted at cap: no woodcutters work when Timber storage is full (#85).
	if woodcutters > 0 and canopy_density > 0.01 and _cap_room("Timber", caps) > 0:
		var foreman_mult: float = 1.0 + FOREMAN_BONUS * _get_assigned_count("foreman")
		var timber_yield = max(1, roundi(woodcutters * 4 * fertilities.get("Timber", 0.0) * canopy_density * foreman_mult))
		# Respect the cap room — production halts at the storage cap, never overflows
		var cap_room: int = _cap_room("Timber", caps)
		timber_yield = min(timber_yield, cap_room)
		var shortfall: int = _construction_shortfall()
		var to_allocated: int = min(timber_yield, shortfall)
		if to_allocated > 0:
			allocated_construction_resources["Timber"] = allocated_construction_resources.get("Timber", 0) + to_allocated
		stockpile["Timber"] = stockpile.get("Timber", 0) + timber_yield - to_allocated
		canopy_density = max(0.0, canopy_density - (timber_yield * 0.002))
	
	# Linked Ecosystem Foraging Math — halts per-resource at cap (#85)
	if foragers > 0:
		var foreman_mult: float = 1.0 + FOREMAN_BONUS * _get_assigned_count("foreman")
		var berry_room: int = _cap_room("Berries", caps)
		var mushroom_room: int = _cap_room("Mushrooms", caps)
		if berry_room > 0:
			var berry_yield = min(roundi(foragers * 5 * fertilities.get("Berries", 0.0) * foreman_mult), berry_room)
			stockpile["Berries"] = stockpile.get("Berries", 0) + berry_yield
		if mushroom_room > 0:
			# Shifting mushroom yields based directly on how badly the canopy is clear-cut
			var mushroom_yield = min(roundi(foragers * 3 * fertilities.get("Mushrooms", 0.0) * canopy_density * foreman_mult), mushroom_room)
			stockpile["Mushrooms"] = stockpile.get("Mushrooms", 0) + mushroom_yield

## Sums the per-resource caps of COMPLETED buildings (#85: caps stack).
func _zone_storage_caps() -> Dictionary:
	var caps: Dictionary = {}
	for building in buildings:
		if not building.is_completed:
			continue
		for resource_name in building.blueprint.storage_caps:
			caps[resource_name] = caps.get(resource_name, 0) + int(building.blueprint.storage_caps[resource_name])
	return caps

## How much more of a resource can be stored (999999 when uncapped —
## production never halts for uncapped resources).
func _cap_room(resource_name: String, caps: Dictionary) -> int:
	if not caps.has(resource_name):
		return 999999
	return max(0, caps[resource_name] - stockpile.get(resource_name, 0))

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
