# Technical Design Document (TDD) — Game Coordinator Module

## 1. Terminology
This section defines terms specific to the `GameCoordinator` module:
* **GameCoordinator**: The absolute root Node in the active gameplay scene tree. It acts as the master conductor for game loop ticks, bootstrap orchestration, and state persistence.
* **GameModule**: A common interface/contract that sub-modules must implement (`initialize_module()`, `process_tick()`, and `get_save_snapshot()`) to be managed by the `GameCoordinator`.
* **Context Passing**: The pattern where the `GameCoordinator` passes the global state resource down into individual modules via function parameters during simulation ticks.
* **Stateless Module**: A module design style where individual modules carry no persistent frame-to-frame simulation variables in memory, relying entirely on mutating the passed state context.
* **Master Clock**: The central Godot `Timer` node managed by `GameCoordinator` that triggers periodic game state ticks (e.g., daily simulation steps).
* **Bootstrap Sequence**: The step-by-step ordered initialization process of all active gameplay sub-modules triggered by `GameCoordinator` at game startup.
* **Save Game File**: A unified custom resource (`SaveGameFile`) that stores serialized state snapshots from all sub-modules.

---

## 2. Architectural Position & Boundary Rules
The `GameCoordinator` is the absolute root node of the active gameplay scene tree. It serves as the master lifecycle anchor and conductor for execution.

### 2.1 Structural Constraints & Context Passing
* **The Coordination Rule**: The `GameCoordinator` is strictly an orchestration layer. It possesses master game state containers (`Resource` data objects) and drives execution by explicitly pushing data down into child modules via function arguments (**Context Passing**).
* **Stateless Modules**: Core modules (e.g., `ManagementModule`, `WarfareModule`) are completely stateless frame-to-frame. They store no persistent entity/player data variables. They take the passed context, execute domain calculations or mutations on it, and exit.
* **Direct vs. Indirect Visibility**: The `GameCoordinator` holds direct, strongly-typed references to its child modules. However, it remains decoupled from domain-specific entity mechanics and never reasons about what a module does with data — only invoking the uniform `GameModule` interface.

### 2.2 The GameModule Contract
To keep the coordinator generic, every child module conforms to a uniform duck-typed contract:
- `initialize_module() -> void` — module self-setup.
- `process_tick(context: Resource) -> void` — process and mutate the passed state context for one simulation step.
- `get_save_snapshot() -> Dictionary` — return a serializable snapshot of the module's state.

Because the coordinator only ever calls these methods, adding or removing a module requires zero modifications to coordinator code.

---

## 3. Domain Objects

### 3.1 GameCoordinator (Entity)
The primary controller and orchestrator of the core simulation loop, lifecycle initialization, and persistence.
* **Script:** `game_coordinator.gd`
* **Variables:**
  * `@export var game_context: Resource` — The master game state container holding all game/simulation data.
  * `@export var module_init_order: Array[StringName]` — List of module node names specifying the order in which they should be bootstrapped.
  * `@export var daily_tick_rate_seconds: float` — Time in seconds between daily simulation ticks.
  * `@onready var modules: Array[Node]` — List of collected direct child nodes implementing the `GameModule` contract.
  * `var _simulation_timer: Timer = null` — The timer node driving simulation ticks.
  * `var _current_game_day: int = 1` — Tracks the elapsed simulation days.
* **Functions:**
  * `_ready() -> void` (Private) — Bootstraps modules and initializes the clock.
  * `_collect_modules() -> Array[Node]` (Private) — Scans child nodes and filters those that implement the `GameModule` contract.
  * `_bootstrap_sequence() -> void` (Private) — Sequentially initializes each discovered module in order.
  * `_initialize_master_clock() -> void` (Private) — Spawns and configures the daily tick timer.
  * `_on_simulation_tick_elapsed() -> void` (Private) — Callback that increments the day counter and runs module tick logic.
  * `execute_session_save(slot_name: String) -> void` (Public) — Compiles snapshots from child modules and saves them to a resource file.

### 3.2 GameModule (Abstract Contract)
The interface implemented by all core sub-modules. It defines three key methods:
* **Functions:**
  * `initialize_module() -> void` — Prepares the module for execution.
  * `process_tick(context: Resource) -> void` — Evaluates domain logic and mutates the passed context.
  * `get_save_snapshot() -> Dictionary` — Returns a serialized copy of any module-specific configuration or temporary state.

### 3.3 SaveGameFile (Resource / Value Object)
A custom resource class acting as the container for serializing and deserializing game sessions.
* **Script / Resource Class:** `save_game_file.gd` (registers as `SaveGameFile`)
* **Variables:**
  * `meta_day_count: int` — The day counter on save.
  * `meta_save_time: String` — System timestamp when the save was executed.
  * `snapshots: Dictionary` — Maps each module's name to its serialized snapshot `Dictionary`.

---

## 4. Scene / Node Hierarchy

This section details the Godot scene structure representing the game coordinator module.

### 4.1 GameCoordinator Scene (`res://scenes/gamecoordinator/GameCoordinator.tscn`)
The `GameCoordinator` scene is the master gameplay scene that orchestrates the execution flow of all simulation sub-modules and anchors the game world simulation and UI.

* **GameCoordinator** (Node, Scene Root)
  * Script: `res://scripts/gamecoordinator/game_coordinator.gd`
  * Properties:
    * `game_context`: `Resource` (The master game state context container)
    * `module_init_order`: `["ManagementModule", "WarfareModule"]`
    * `daily_tick_rate_seconds`: `3.0`
  * **ManagementModule** (Node, Static Child)
    * Script: `res://scripts/management/management_module.gd`
  * **WarfareModule** (Node, Static Child)
    * Script: `res://scripts/warfare/warfare_module.gd`
  * **UICoordinator** (CanvasLayer, Static Child)
    * Script: `res://scripts/ui/ui_coordinator.gd`
    * Note: Isolated from simulation, updates presentation elements via signals on `EventBus`.
  * **WorldSimulation** (Node3D, Static Child)
    * Instanced Scene: `res://scenes/world/World.tscn`
    * Note: Contains the environment, terrain, player, and spatial NPCs.

### 4.2 Runtime-Only Dynamic Nodes
* **_simulation_timer** (Timer, Dynamic Child)
  * Instantiated programmatically by `_initialize_master_clock()`.
  * Auto-starts with `wait_time = daily_tick_rate_seconds`.
  * Connected to the coordinator's `_on_simulation_tick_elapsed()` callback.

```
[Runtime Scene Tree Root]
 └── GameCoordinator (Node) <--- [Attached: game_coordinator.gd]
      ├── ManagementModule (Node)
      ├── WarfareModule (Node)
      ├── UICoordinator (CanvasLayer) <--- [Attached: ui_coordinator.gd]
      └── WorldSimulation (Node3D) <--- Instanced: World.tscn
```


---

## 5. Systems

This section describes the core "cross-script" processes, operational lifecycles, and how the `GameCoordinator` system interfaces with external systems.

### 5.1 System Bootstrap Sequence (Cross-Script Initialization Process)
During `_ready()`, the `GameCoordinator` forces an explicit sequence for initialization. This ensures that parent systems and APIs are registered and ready before child modules or other nodes attempt to locate them via the `ServiceLocator`.

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

### 5.2 Synchronized Game Tick Lifecycle (Data Mutation Pipeline)
The simulation is driven by a single master clock. The coordinator passes the state context through sub-module update routines sequentially to allow predictable, cascade-style state modifications.

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

### 5.3 Signal & Data Flow Boundaries (UI and Presentation Interfaces)
To keep simulation logic separated from view representation:
1. **Simulation Domain (Inside/Between Modules):** Modules read/mutate the context passed via `process_tick()`. They do **not** use signals to trigger gameplay actions in other modules.
2. **Presentation Domain (Outside Modules):** Modules emit "fire-and-forget" events on the global `EventBus` to notify visual observers (e.g. `UICoordinator` or Audio managers) of changes.

| Domain Scope | Execution Mechanism | Purpose |
| :--- | :--- | :--- |
| **Inside / Between Modules** | `GameCoordinator` (Context Passing) | Master state data is passed down to modules via `process_tick(game_context)`. Modules mutate context directly. Core modules **never** emit signals to trigger other core modules. |
| **Outside Modules** | Global `EventBus` | Visual, audio, and UI updates. Modules emit signals on `EventBus` (e.g. `EventBus.populants_starving.emit(count)`) as fire-and-forget notifications for UI widgets or SFX players. |

#### Example Context & Event Processing inside a Module:
```gdscript
## ManagementModule.gd
func process_tick(context: Resource) -> void:
	# 1. Take passed context and perform domain logic (Inside Module)
	var starving_count = calculate_starvation(context)
	context.food_supplies -= starving_count
	
	# 2. Emit notification for external observers (Outside Module)
	if starving_count > 0:
		EventBus.populants_starving.emit(starving_count)
```

### 5.4 External System Integration (Service Locator & GOAP AI Overlaps)
Other autonomous subsystems (e.g., the player, spatial NPC agents, or GOAP AI agents running on individual populants) cannot directly access or mutate the `GameCoordinator` state. Instead:
* **Service Registration:** During their `initialize_module()` phase, simulation modules register their public boundary APIs (e.g. `ManagementAPI`) to the autoloaded `ServiceLocator`.
* **Data Reading:** Decoupled nodes (such as `ManagementPopulantComponent` or a GOAP Action script) query the `ServiceLocator` to retrieve the active service API and fetch read-only snapshots or submit transaction requests (e.g., assigning a worker to a node via `order_building()`).
* **Decoupling Boundary:** This design ensures that the simulation tick pipeline remains completely unaffected by visual NPCs, player movement, or physical spatial interactions.


---

## 6. APIs

### 6.1 GameCoordinator API
The coordinator exposes the following public functions for triggering session persistence:
* `execute_session_save(slot_name: String) -> void`

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

### 6.2 GameModule Contract API
Any child node of `GameCoordinator` will be collected as a module if it implements these methods:
* `initialize_module() -> void`
* `process_tick(context: Resource) -> void`
* `get_save_snapshot() -> Dictionary`

---

## 7. File Manifest

This module consists of the following project files and paths:

| File Type | Project Path | Description |
| :--- | :--- | :--- |
| **Scene** | `res://scenes/gamecoordinator/GameCoordinator.tscn` | The primary gameplay scene root containing the coordinator node structure. |
| **Script** | `res://scripts/gamecoordinator/game_coordinator.gd` | The master simulation lifecycle conductor and clock manager script. |
| **Resource Script** | `res://scripts/resources/save_game_file.gd` | Registers `SaveGameFile`, storing aggregated serializable data snapshots of the game simulation state. |
| **Technical Design** | `res://docs/design/game-coordinator-module-tdd.md` | This technical design document. |

