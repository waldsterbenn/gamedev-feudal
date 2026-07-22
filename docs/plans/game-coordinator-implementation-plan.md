# Implementation Plan — GameCoordinator Module

> **Scope:** This plan implements the `GameCoordinator` as defined in
> `docs/design/game-coordinator-module-tdd.md`.
>
> **Out of scope (deferred):**
> - Hooking up any module other than `ManagementModule` (Phase 2).
> - `SaveGameFile` resource and `execute_session_save()` (future phase).

---

## Phase 1 — Core Infrastructure

Goal: A working `GameCoordinator` scene that boots, runs the master clock, and
calls `process_tick()` on any child modules it discovers. No real modules yet.

### Step 1.1 — Create the `game_coordinator.gd` script

Create `res://scripts/gamecoordinator/game_coordinator.gd`.

Implement:
- `@export var game_context: Resource` — left unassigned for now.
- `@export var module_init_order: Array[StringName]` — empty by default.
- `@export var daily_tick_rate_seconds: float = 3.0`
- `@onready var modules: Array[Node]` — populated by `_collect_modules()`.
- `var _simulation_timer: Timer = null`
- `var _current_game_day: int = 1`
- `_ready()` — calls `_bootstrap_sequence()` then `_initialize_master_clock()`.
- `_collect_modules()` — duck-type scan of direct children for the three
  GameModule methods.
- `_bootstrap_sequence()` — respects `module_init_order`, falls back to
  discovery order.
- `_initialize_master_clock()` — creates, configures, and adds the `Timer`.
- `_on_simulation_tick_elapsed()` — increments `_current_game_day`, calls
  `module.process_tick(game_context)` for each module.

> **Do NOT implement** `execute_session_save()` yet.

---

### Step 1.2 — Create the `GameCoordinator.tscn` scene

Create `res://scenes/gamecoordinator/GameCoordinator.tscn`.

Scene structure:
```
GameCoordinator  (Node)
├── UICoordinator  (CanvasLayer)   ← instance res://scenes/ui/UICoordinator.tscn
└── WorldSimulation  (Node3D)      ← instance res://scenes/world/World.tscn
```

Attach `game_coordinator.gd` to the root node.

Set the Inspector export values:
- `daily_tick_rate_seconds = 3.0`
- `module_init_order = []` (empty — no modules yet)
- `game_context` — leave empty for now.

> The `UICoordinator` and `WorldSimulation` are **not** GameModule children;
> `_collect_modules()` will skip them because they do not implement the
> GameModule contract. They are present here to anchor the full gameplay scene.

---

### Step 1.3 — Verify Phase 1

Run headless to confirm no errors on startup:
```
godot --path ./src/feudal-age/ --headless --quit
```

Expected console output:
```
GC: Commencing system bootstrap...
GC: Bootstrap sequence executed cleanly.
GC: Processing Day Ticks: 2
GC: Processing Day Ticks: 3
...
```

---

## Phase 2 — Hook Up ManagementModule (deferred)

> **Prerequisite:** Phase 1 must be complete and verified.

Goal: `ManagementAPI` is adapted to implement the GameModule contract so the
coordinator can call `initialize_module()` and `process_tick()` on it each day.

### Step 2.1 — Create a `ManagementModule` wrapper node scene

The existing `ManagementAPI.gd` is currently a plain `Node` that registers
itself with `ServiceLocator` in its own `_ready()`. It already has
`_on_day_changed()` — the logic that runs per day tick.

Create a thin wrapper scene `res://scenes/management/ManagementModule.tscn`
with the following child structure:
```
ManagementModule  (Node)             ← new script: management_module.gd
└── ManagementAPI  (Node)            ← existing ManagementAPI.gd
```

### Step 2.2 — Create `management_module.gd`

Implement the GameModule contract:
- `initialize_module()` — no-op for now; `ManagementAPI._ready()` already
  handles ServiceLocator registration.
- `process_tick(context: Resource)` — forwards the call to
  `ManagementAPI._on_day_changed(_current_game_day)`. The `context` parameter
  is accepted but unused until `FiefStateResource` is introduced.
- `get_save_snapshot() -> Dictionary` — returns `{}` (empty stub until the
  save system is implemented).

### Step 2.3 — Add `ManagementModule` to `GameCoordinator.tscn`

Add the `ManagementModule` instance as a child of `GameCoordinator`:
```
GameCoordinator  (Node)
├── ManagementModule  (Node)         ← instance ManagementModule.tscn
├── UICoordinator  (CanvasLayer)
└── WorldSimulation  (Node3D)
```

Update Inspector export values on `GameCoordinator`:
- `module_init_order = ["ManagementModule"]`

### Step 2.4 — Verify Phase 2

Run headless and confirm:
```
GC: Commencing system bootstrap...
GC: Bootstrap sequence executed cleanly.
GC: Processing Day Ticks: 2
...
```
Confirm that `ManagementAPI._on_day_changed()` is invoked for each tick (add a
temporary `print` statement, remove after verification).

---

## Deferred Phases (not in scope now)

| Phase | Description |
| :--- | :--- |
| **Phase 3** | Add `SocialModule` and `WarfareModule` when those modules are built. |
| **Phase 4** | Implement `SaveGameFile` resource, wire `execute_session_save()`, add save/load UI trigger. |
| **Phase 5** | Introduce `FiefStateResource` (owned by ManagementModule), hook it into the GameCoordinator `game_context` export. |
