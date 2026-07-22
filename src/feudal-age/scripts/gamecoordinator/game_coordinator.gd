## GameCoordinator
## The absolute root Node of the active gameplay scene tree.
## Acts as the master conductor for game loop ticks, bootstrap orchestration,
## and state persistence.
##
## Path: res://scripts/gamecoordinator/game_coordinator.gd
extends Node

# ---------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------

## The master game state container. Leave unassigned until FiefStateResource is introduced.
@export var game_context: Resource

## Node names of child modules, specifying their bootstrap initialization order.
@export var module_init_order: Array[StringName] = []

## Real-time seconds between each simulated game day tick.
@export var daily_tick_rate_seconds: float = 3.0

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------

## Collected child nodes that implement the GameModule contract.
var modules: Array[Node] = []

## The timer node driving simulation ticks.
var _simulation_timer: Timer = null

## Tracks the number of elapsed simulation days.
var _current_game_day: int = 1

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	modules = _collect_modules()
	_bootstrap_sequence()
	_initialize_master_clock()

# ---------------------------------------------------------------------------
# Private helpers
# ---------------------------------------------------------------------------

## Scans direct children and returns those that implement the GameModule contract
## (duck-typed: must have initialize_module, process_tick, and get_save_snapshot).
func _collect_modules() -> Array[Node]:
	var result: Array[Node] = []
	for child in get_children():
		if child.has_method("initialize_module") \
				and child.has_method("process_tick") \
				and child.has_method("get_save_snapshot"):
			result.append(child)
	return result


## Initializes each discovered module in the order specified by module_init_order.
## Any modules not listed are initialized after those that are.
func _bootstrap_sequence() -> void:
	print("GC: Commencing system bootstrap...")

	var ordered: Array[Node] = []
	var remaining := modules.duplicate()

	for module_name in module_init_order:
		for m in remaining:
			if m.name == module_name:
				ordered.append(m)
				remaining.erase(m)
				break
	ordered.append_array(remaining)

	for module in ordered:
		module.initialize_module()

	print("GC: Bootstrap sequence executed cleanly.")


## Creates, configures, and adds the master simulation Timer as a child node.
func _initialize_master_clock() -> void:
	_simulation_timer = Timer.new()
	_simulation_timer.name = "_SimulationTimer"
	_simulation_timer.wait_time = daily_tick_rate_seconds
	_simulation_timer.autostart = true
	_simulation_timer.timeout.connect(_on_simulation_tick_elapsed)
	add_child(_simulation_timer)

# ---------------------------------------------------------------------------
# Tick callback
# ---------------------------------------------------------------------------

## Called each time the master clock ticks. Increments the day counter and
## dispatches process_tick(game_context) to every registered module.
func _on_simulation_tick_elapsed() -> void:
	_current_game_day += 1
	print("GC: Processing Day Ticks: ", _current_game_day)
	for module in modules:
		module.process_tick(game_context)

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Compiles save snapshots from all child modules and writes a SaveGameFile
## resource to disk. NOTE: Not implemented in Phase 1 — deferred to Phase 4.
func execute_session_save(_slot_name: String) -> void:
	push_warning("GC: execute_session_save() is not yet implemented.")
