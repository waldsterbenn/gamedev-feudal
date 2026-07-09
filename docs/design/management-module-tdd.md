Technical Design Document (TDD) — Management Module
1. Architectural Position & System Discovery
The management module functions as a headless background data simulation. It does not handle physics, 3D asset instantiation, or direct character steering. It sits entirely within the domain of the game's data layer, completely decoupled from the Warfare Module, Social Module, and the 3D Visual Scene Tree (Terrain3D).
1.1 How External Modules Locate the Management API
To ensure strict system isolation, other modules (like the GOAP Brain or Social Module) never hardcode references or search the scene tree for the management module. Instead, discovery is handled via a global Service Locator Pattern implemented as an autoloaded engine singleton.
GDScript
# ServiceLocator.gd (Autoload Singleton)
extends Node

var management_api: ManagementAPI = null

func register_management_service(api: ManagementAPI) -> void:
	management_api = api

func get_management_service() -> ManagementAPI:
	assert(management_api != null, "Management API requested before initialization!")
	return management_api

During initialization, the controller responsible for the management module registers itself. When an NPC’s GOAP Brain needs data, it dynamically requests access via the service locator singleton.
1.2 Inputs Required by the Management Module
Tick/Time Driver: A signal from a global time manager indicating the turn, hour, or day boundary to process economic cycles.
UI Input Layer: Explicit system requests caught from the user framework to interact with management structures:
toggle_management_view(is_active: bool) -> Enables spatial visibility/interaction layers.
inspect_node(node_id: int) -> Queries specific snapshot metrics.
establish_camp(node_id: int, owner_id: String) -> Mutates node state to camp tier.
recruit_populant_to_faction(character_id: int, lord_id: String) -> Claims an NPC.
assign_populant_to_node(character_id: int, target_node_id: int) -> Binds residency.
order_building(node_id: int, blueprint: BuildingData) -> Initializes a new construction queue element.
1.3 Data Exposed by the Management Module via ManagementAPI
The ManagementAPI class exposes an optimized, read-only query protocol. It specifically masks the deep data fields of ZoneNode resources, returning only plain structures (Dictionary, Vector3, strings) to external systems.
GDScript
# ManagementAPI.gd (Exposed Interface Instance)
extends Node
class_name ManagementAPI

# Internal reference to the complete array of simulated world data resources
var _world_nodes: Dictionary = {} 

func _ready() -> void:
	ServiceLocator.register_management_service(self)

## API Query: Returns the macro-assignment for a given agent
func get_character_assignment(char_id: int) -> Dictionary:
	# Searches internal ZoneNode records for where the character ID is allocated
	# Returns: {"node_id": int, "job_type": String, "work_target_position": Vector3}
	return {}

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

2. Core Class Architecture & Godot Scene Mapping
Data states are contained inside custom Resource definitions to simplify saving and serialization. However, data requires pairing with physical 3D spaces on the Terrain3D map. This is achieved through the Resource-to-Scene Attachment Rule.
2.1 The Resource-to-Scene Attachment Rule
Data-Only Entities: ZoneNode, BuildingData, and BuildingInstance are raw Resource objects. They have no physical presence and live inside custom data arrays.
Spatial Anchors (Area3D): Every data ZoneNode resource maps 1:1 to an instantiated ZoneAnchor3D scene placed in the world. The ZoneNode resource is attached directly as an exported property of that scene's root script.
Visibility Filtering: When toggle_management_view(true) is received, ZoneAnchor3D scenes enable their visual indicator meshes and activate their collision layers to allow mouse selection. When false, they go dormant, clearing collision overhead entirely.
Dynamic Building Scenes: When a building completes construction, the ZoneAnchor3D instantiates a matching visual 3D scene (e.g., LumberHut.tscn). The static configuration BuildingData and dynamic state BuildingInstance resources are passed directly into the instantiated scene script, allowing the 3D meshes to adapt their appearance based on structural health or progression metrics.
2.2 Component & Class Definitions
GDScript
# ManagementPopulantComponent.gd (Attached inside the physical 3D NPC Scene)
extends Node
class_name ManagementPopulantComponent

@export var character_id: int

# Faction & Residency State (Exposed to GOAP and Management Systems)
@export var serving_lord_id: String = "none" # e.g., "player", "rival_lord_1", "none"
@export var assigned_node_id: int = -1       # Coordinates where this Populant resides

# The skill string this Populant registers into the matching pool
@export var qualification_profile: String = "unskilled" 

# Reference to the physical 3D marker on Terrain3D where the NPC travels to execute jobs
var current_3d_workplace_target: Marker3D = null

GDScript
# ZoneNode.gd (Data Resource)
extends Resource
class_name ZoneNode

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

## Helper: Checks if the node has enough available resources
func has_available_resources(requirements: Dictionary) -> bool:
	for resource_name in requirements:
		var required_amount: int = requirements[resource_name]
		var available_amount: int = stockpile.get(resource_name, 0)
		if available_amount < required_amount:
			return false
	return true

GDScript
# BuildingData.gd (Static Blueprint Config Resource)
extends Resource
class_name BuildingData

@export var building_id: String        # e.g., "charcoal_stack", "covered_work_area", "forager_post"
@export var display_name: String
@export var build_cost: Dictionary = {"Timber": 25}
@export var total_work_required: float = 50.0 
@export var max_jobs: int = 2
@export var job_type: String           

GDScript
# BuildingInstance.gd (Dynamic State Resource)
extends Resource
class_name BuildingInstance

@export var blueprint: BuildingData
@export var is_completed: bool = false
@export var construction_progress: float = 0.0 
@export var integrity: float = 1.0             
@export var assigned_worker_ids: Array[int] = []

GDScript
# WorkerData.gd (Structural Link Resource)
extends Resource
class_name WorkerData

@export var character_id: int
@export var qualification: String

3. Core Balances & Designer Configurations
3.1 Job Prioritization Balancing Array
To alter the game's core behavioral priority profile as a designer without restructuring matching routines, jobs are evaluated sequentially against an ordered index array. Changing the string order shifts allocation weight.
GDScript
# JobPriorities.gd (Global System Constant Script)
class_name JobPriorities

# Edit this array order to change game balance priorities globally
const HIERARCHY: Array[String] = [
	"sustenance",   # High Priority: Gathering food so the camp doesn't starve
	"builder",      # Mid Priority: Construction of ordered blueprints
	"woodcutter",   # Lower Priority: Raw extraction
	"forager"       # Production
]

static func get_priority_weight(job_type: String) -> int:
	var index = HIERARCHY.find(job_type)
	if index == -1:
		return 999 
	return index

3.2 Dietary Hierarchy Table
Governs consumption execution strings. Populants systematically chew through localized inventories according to this list.
GDScript
# DietPriorities.gd (Global System Constant Script)
class_name DietPriorities

const CONSUMPTION_ORDER: Array[String] = [
	"Berries",
	"Mushrooms"
]

4. Core Simulations & Execution Algorithms
4.1 Master Simulation Tick Routine
Every processing rotation cycle, ZoneNode.gd updates its entire logical data state sequentially:
GDScript
## System Master Function executing local economic updates
func process_management_tick() -> void:
	if current_tier == SettlementTier.WILDERNESS:
		return
		
	_resolve_workforce_allocation()  # Step 1: Dynamic Qualification Matching
	_deduct_sustenance_inventories() # Step 2: Food Consumption Check
	_process_construction_progress() # Step 3: Construction Progress Processing
	_execute_production_and_labor()  # Step 4: Environmental Extraction Mechanics
	_enforce_storage_caps()          # Step 5: Warehouse Auditing

4.2 API Execution Control Functions
GDScript
# Inside ManagementAPI.gd

signal settlement_tier_changed(node_id: int, new_tier_string: String)
signal construction_failed_no_resources(node_id: int, building_id: String)
signal operation_failed(reason: String)

## Executed when the player activates the 'Establish Camp' UI command
func establish_camp(node_id: int, owner_id: String = "player") -> void:
	var node: ZoneNode = _world_nodes.get(node_id)
	if not node or node.current_tier != ZoneNode.SettlementTier.WILDERNESS:
		operation_failed.emit("Invalid or already settled node.")
		return
		
	# Mutate state to camp completely barren - zero items/jobs seeded
	node.current_tier = ZoneNode.SettlementTier.CAMP
	
	var tier_name = ZoneNode.SettlementTier.keys()[node.current_tier]
	settlement_tier_changed.emit(node_id, tier_name)

## Executed when the player issues a build blueprint command
func order_building(node_id: int, blueprint: BuildingData) -> bool:
	var node: ZoneNode = _world_nodes.get(node_id)
	if not node:
		return false
		
	# 1. Available resource check
	if not node.has_available_resources(blueprint.build_cost):
		construction_failed_no_resources.emit(node_id, blueprint.building_id)
		return false
		
	# 2. Mutate stockpile storage down & allocate materials to construction hold
	for resource_name in blueprint.build_cost:
		var cost: int = blueprint.build_cost[resource_name]
		node.stockpile[resource_name] -= cost
		node.allocated_construction_resources[resource_name] = node.allocated_construction_resources.get(resource_name, 0) + cost
		
	# 3. Queue incomplete framework
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
	
	return true

4.3 Node Simulation Subroutines
GDScript
# Inside ZoneNode.gd

signal building_completed(node_id: int, building_id: String)
signal populants_starving(node_id: int, starving_count: int)

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



