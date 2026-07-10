# Technical Design Document (TDD) — Game Coordinator Module
1. Architectural Position & Boundary Rules
The GameCoordinator is the absolute root node of the active gameplay scene tree. It serves as the master lifecycle anchor for the execution of Wilderness Fief.
1.1 Structural Constraints
The Coordination Rule: The GameCoordinator is strictly an orchestration layer. It must possess zero domain-specific knowledge. It does not calculate resource yields, compute combat damage, or manage character relationship trees.
Direct vs. Indirect Visibility: The GameCoordinator has direct pointer access to its immediate child modules (ManagementModule, WarfareModule, SocialModule). However, it remains completely decoupled from individual entity elements, such as character agents or specific environment props.
2. Structural Topology & Scene Mapping
Within the Godot scene tree, the GameCoordinator sits at the top of the local branch. The independent game modules are instantiated as direct children of this coordinator node.
[Runtime Scene Tree Root]
 └── GameCoordinator (Node) <--- [Attached: game_coordinator.gd]
      ├── ManagementModule (Node)
      ├── SocialModule (Node)
      └── WarfareModule (Node)

3. Core Class & Variable Definitions
The GameCoordinator handles the master loop timing, file save system interactions, and the operational bootstrapping timeline.
GDScript
## game_coordinator.gd
extends Node
class_name GameCoordinator

## Explicit, strongly-typed references to core module anchors
@onready var management_module: Node = $ManagementModule
@onready var social_module: Node = $SocialModule
@onready var warfare_module: Node = $WarfareModule

## Master Simulation Loop Parameters
@export var daily_tick_rate_seconds: float = 3.0
var _simulation_timer: Timer = null
var _current_game_day: int = 1

func _ready() -> void:
	_bootstrap_sequence()
	_initialize_master_clock()

4. Operational Lifecycles & Execution Flow
4.1 The Bootstrap Sequence
To eliminate race conditions and initialization dependencies (e.g., preventing the Social system from trying to reference non-existent map nodes), the coordinator forces an explicit, step-by-step loading timeline during _ready().
GDScript
### Dictates the exact order of initialization across the codebase
func _bootstrap_sequence() -> void:
	print("GC: Commencing system bootstrap...")
	
	# Step 1: Initialize raw world parameters, resource registers, and node grids
	if management_module.has_method("initialize_module"):
		management_module.initialize_module()
		
	# Step 2: Initialize human elements, lineages, and emotional state structures
	if social_module.has_method("initialize_module"):
		social_module.initialize_module()
		
	# Step 3: Initialize tactical, physics-based combat tracking and threat maps
	if warfare_module.has_method("initialize_module"):
		warfare_module.initialize_module()
		
	# Step 4: Inter-module event wiring via standard Godot signal mapping
	_wire_cross_module_events()
	
	print("GC: Bootstrap sequence executed cleanly.")

4.2 Cross-Module Event Interception (The Routing Layer)
Following the "Call Down, Signal Up" protocol, modules never communicate horizontally. Instead, they emit blind signals which the GameCoordinator catches and redistributes to the appropriate recipient systems.
GDScript
### Binds decoupled modules together at the root level using standard Godot signals
func _wire_cross_module_events() -> void:
	# Context: Management reports starvation -> Social drops happiness & GOAP alters behavior
	if management_module.has_signal("populants_starving"):
		management_module.populants_starving.connect(_on_management_reported_starvation)
		
	# Context: Warfare reports a character casualty -> Social updates family trees/grief
	if warfare_module.has_signal("character_killed_in_combat"):
		warfare_module.character_killed_in_combat.connect(_on_warfare_reported_casualty)

func _on_management_reported_starvation(node_id: int, starving_count: int) -> void:
	# Safely route management data straight into the social simulation domain
	social_module.apply_starvation_morale_penalty(node_id, starving_count)

func _on_warfare_reported_casualty(character_id: int) -> void:
	# Safely pass physical warfare casualties straight into the lineage data simulation
	social_module.process_character_death_impact(character_id)

4.3 The Synchronized Game Tick Lifecycle
To prevent data tearing (where one module reads economic data before another has finished updating it during the same frame), the GameCoordinator drives a single master clock and calls sub-module update routines sequentially.
GDScript
func _initialize_master_clock() -> void:
	_simulation_timer = Timer.new()
	_simulation_timer.wait_time = daily_tick_rate_seconds
	_simulation_timer.autostart = true
	_simulation_timer.timeout.connect(_on_simulation_tick_elapsed)
	add_child(_simulation_timer)

### Controlled sequence of processing loops executed every tick
func _on_simulation_tick_elapsed() -> void:
	_current_game_day += 1
	print("GC: Processing Day Ticks: ", _current_game_day)
	
	# 1. Update the economic, consumption, and production ledgers first
	if management_module.has_method("process_management_tick"):
		management_module.process_management_tick()
		
	# 2. Update relationship shifts, moral decay, or faction splits based on current states
	if social_module.has_method("process_social_tick"):
		social_module.process_social_tick()

5. Centralized Save/Load Data Persistence Engine
Because save files are a compilation of states across the entire application, the GameCoordinator operates as the data clearinghouse. It requests data packets from each child module, rolls them up into a centralized configuration file, and writes it to disk.
GDScript
### Compiles isolated sub-module snapshots into a unified save profile
func execute_session_save(slot_name: String) -> void:
	var save_path = "user://saves/" + slot_name + ".tres"
	
	# Instantiate a clean global SaveGame Resource (Custom Resource class)
	var save_file = SaveGameFile.new()
	save_file.meta_day_count = _current_game_day
	save_file.meta_save_time = Time.get_datetime_string_from_system()
	
	# Query modules for independent snapshot dictionaries
	if management_module.has_method("get_save_snapshot"):
		save_file.management_snapshot = management_module.get_save_snapshot()
		
	if social_module.has_method("get_save_snapshot"):
		save_file.social_snapshot = social_module.get_save_snapshot()
		
	# Write configuration data to the user's local disk space
	var error = ResourceSaver.save(save_file, save_path)
	if error == OK:
		print("GC: Session saved successfully to: ", save_path)
	else:
		print("GC: Critical failure saving session data. Error code: ", error)


