# Technical Design Document (TDD) — Game Coordinator Module

## 1. Architectural Position & Boundary Rules
The `GameCoordinator` is the absolute root node of the active gameplay scene tree. It serves as the master lifecycle anchor and conductor for execution.

### 1.1 Structural Constraints & Context Passing
* **The Coordination Rule**: The `GameCoordinator` is strictly an orchestration layer. It possesses master game state containers (`Resource` data objects) and drives execution by explicitly pushing data down into child modules via function arguments (**Context Passing**).
* **Stateless Modules**: Core modules (e.g., `ManagementModule`, `WarfareModule`, `SocialModule`) are completely stateless frame-to-frame. They store no persistent entity/player data variables. They take the passed context, execute domain calculations or mutations on it, and exit.
* **Direct vs. Indirect Visibility**: The `GameCoordinator` holds direct, strongly-typed references to its child modules. However, it remains decoupled from domain-specific entity mechanics and never reasons about what a module does with data — only invoking the uniform `GameModule` interface.

### 1.2 The GameModule Contract
To keep the coordinator generic, every child module conforms to a uniform duck-typed contract:
- `initialize_module() -> void` — module self-setup.
- `process_tick(context: Resource) -> void` — process and mutate the passed state context for one simulation step.
- `get_save_snapshot() -> Dictionary` — return a serializable snapshot of the module's state.

Because the coordinator only ever calls these methods, adding or removing a module requires zero modifications to coordinator code.

---

## 2. Structural Topology & Scene Mapping

```
[Runtime Scene Tree Root]
 └── GameCoordinator (Node) <--- [Attached: game_coordinator.gd]
      ├── ManagementModule (Node)   \  Child modules — all implement
      ├── SocialModule (Node)        > the GameModule contract (§1.2)
      └── WarfareModule (Node)      /
```

---

## 3. Core Class & Variable Definitions

```gdscript
## game_coordinator.gd
extends Node
class_name GameCoordinator

## Master Game State Context (Resource holding all fief data)
@export var game_context: FiefStateResource

## Modules are discovered from direct children that implement the GameModule contract
@onready var modules: Array[Node] = _collect_modules()

## Optional init ordering
@export var module_init_order: Array[StringName] = ["ManagementModule", "SocialModule", "WarfareModule"]

## Master Simulation Loop Parameters
@export var daily_tick_rate_seconds: float = 3.0
var _simulation_timer: Timer = null
var _current_game_day: int = 1

func _ready() -> void:
	_bootstrap_sequence()
	_initialize_master_clock()

func _collect_modules() -> Array[Node]:
	var result: Array[Node] = []
	for child in get_children():
		if child.has_method("initialize_module") \
		and child.has_method("process_tick") \
		and child.has_method("get_save_snapshot"):
			result.append(child)
	return result
```

---

## 4. Operational Lifecycles & Execution Flow

### 4.1 The Bootstrap Sequence
The coordinator forces an explicit loading timeline during `_ready()` to initialize sub-modules in sequence before simulation ticks begin.

```gdscript
func _bootstrap_sequence() -> void:
	print("GC: Commencing system bootstrap...")

	var ordered: Array[Node] = []
	var remaining := modules.duplicate()
	for name in module_init_order:
		for m in remaining:
			if m.name == name:
				ordered.append(m)
				remaining.erase(m)
	ordered.append_array(remaining)

	for module in ordered:
		module.initialize_module()

	print("GC: Bootstrap sequence executed cleanly.")
```

### 4.2 Signal & Data Flow Boundaries

To keep architectural roles crystal clear:

| Domain Scope | Execution Mechanism | Purpose |
| :--- | :--- | :--- |
| **Inside / Between Modules** | `GameCoordinator` (Context Passing) | Master state data is passed down to modules via `process_tick(game_context)`. Modules mutate context directly or hand off via sequential coordinator ticks. Core modules **never** emit signals to trigger other core modules. |
| **Outside Modules** | Global `EventBus` | Visual, audio, and UI updates. Modules emit signals on `EventBus` (e.g. `EventBus.populants_starving.emit(count)`) as fire-and-forget notifications for UI widgets or SFX players. |

#### Example Context & Event Processing inside a Module:
```gdscript
## ManagementModule.gd
func process_tick(context: FiefStateResource) -> void:
	# 1. Take passed context and perform domain logic (Inside Module)
	var starving_count = calculate_starvation(context)
	context.food_supplies -= starving_count
	
	# 2. Emit notification for external observers (Outside Module)
	if starving_count > 0:
		EventBus.populants_starving.emit(starving_count)
```

### 4.3 The Synchronized Game Tick Lifecycle
The `GameCoordinator` drives a single master clock and passes the data context through sub-module update routines sequentially.

```gdscript
func _initialize_master_clock() -> void:
	_simulation_timer = Timer.new()
	_simulation_timer.wait_time = daily_tick_rate_seconds
	_simulation_timer.autostart = true
	_simulation_timer.timeout.connect(_on_simulation_tick_elapsed)
	add_child(_simulation_timer)

func _on_simulation_tick_elapsed() -> void:
	_current_game_day += 1
	print("GC: Processing Day Ticks: ", _current_game_day)
	for module in modules:
		module.process_tick(game_context)
```

---

## 5. Centralized Save/Load Data Persistence Engine
The `GameCoordinator` compiles isolated module snapshots into a unified save file.

```gdscript
func execute_session_save(slot_name: String) -> void:
	var save_path = "user://saves/" + slot_name + ".tres"
	var save_file = SaveGameFile.new()
	save_file.meta_day_count = _current_game_day
	save_file.meta_save_time = Time.get_datetime_string_from_system()

	for module in modules:
		save_file.set_snapshot(module.name, module.get_save_snapshot())

	var error = ResourceSaver.save(save_file, save_path)
	if error == OK:
		print("GC: Session saved successfully to: ", save_path)
	else:
		print("GC: Critical failure saving session data. Error code: ", error)
```
