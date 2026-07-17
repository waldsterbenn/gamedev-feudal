# Game Coordinator Implementation Plan

This document covers the phased implementation of the **GameCoordinator**, **UICoordinator**, and **InputRouter** as described in the following TDDs:
- [game-coordinator-module-tdd.md](file:///C:/Users/woodl/GitHub/gamedev-feudal/docs/design/game-coordinator-module-tdd.md)
- [ui-architecture-tdd.md](file:///C:/Users/woodl/GitHub/gamedev-feudal/docs/design/ui-architecture-tdd.md)
- [input-handling-architecture-tdd.md](file:///C:/Users/woodl/GitHub/gamedev-feudal/docs/design/input-handling-architecture-tdd.md)

---

## What This Replaces / Supersedes

The current `feudal-age` project uses a flat, ad-hoc structure:
- `GameManager.gd` (autoload) handles gold, prestige, season timing, and pause state — all mixed together.
- `HUD.gd` directly connects to `EventBus` signals and manages its own display logic.
- Input is handled ad-hoc inside individual nodes.

The Game Coordinator architecture replaces this with a strict, layered scene tree that owns the master clock, bootstraps modules in a guaranteed order, routes cross-module signals, and owns all UI state transitions.

> [!IMPORTANT]
> The day tick clock currently implemented in `GameManager.gd` (Phase 2 of management module) will be **migrated** into `GameCoordinator`. `GameManager` will be deprecated and eventually removed.

---

## Target Scene Tree

```
GameCoordinator (Node)        ← game_coordinator.gd — master lifecycle & clock
├── InputRouter (Node)        ← input_router.gd — input gatekeeper
├── UI (CanvasLayer)          ← ui_coordinator.gd — all UI state transitions
│    ├── StandardHUD (Control)
│    └── ZoneInspectionMenu (PanelContainer)
└── WorldSimulation (Node3D)  ← existing 3D world content moved under here
     ├── TerrainManager
     ├── NPCs ...
     └── ZoneAnchors ...
```

---

## Phase-by-Phase Plan

### Phase 1: GameCoordinator Scene & Script
Establish the root orchestration node and bootstrap sequence.

1. Create `src/feudal-age/scenes/GameCoordinator.tscn` with root node `GameCoordinator` (Node).
2. Create `src/feudal-age/scripts/GameCoordinator.gd`:
   - `@onready` references to `ManagementModule`, `SocialModule`, `WarfareModule` child nodes (stubs for now).
   - `_bootstrap_sequence()`: calls `initialize_module()` on each child module in order (Management → Social → Warfare), then calls `_wire_cross_module_events()`.
   - `_initialize_master_clock()`: creates a `Timer` node with `daily_tick_rate_seconds` (default `3.0s`), connects it to `_on_simulation_tick_elapsed()`.
   - `_on_simulation_tick_elapsed()`: increments `_current_game_day`, emits `EventBus.day_changed`, calls `management_module.process_management_tick()` and `social_module.process_social_tick()` in sequence.
   - `_wire_cross_module_events()`: connects `populants_starving` from ManagementModule to `social_module.apply_starvation_morale_penalty()`.
   - `execute_session_save(slot_name)` / `execute_session_load(slot_name)`: save/load stubs using `SaveGameFile` resource.
3. **Migrate** day timer from `GameManager.gd` into `GameCoordinator`. Remove `current_day`, `day_timer`, `day_duration`, `_update_day()` from `GameManager.gd`.

---

### Phase 2: ManagementModule Wrapper Node
Give the `ManagementAPI` a proper scene-tree home as a named module child of `GameCoordinator`.

1. Create `src/feudal-age/scenes/modules/ManagementModule.tscn`:
   - Root node: `ManagementModule` (Node), script `ManagementModule.gd`.
2. Create `src/feudal-age/scripts/modules/ManagementModule.gd`:
   - Holds a reference to `ManagementAPI` (already registered via `ServiceLocator`).
   - Implements `initialize_module()`: seeds world node data (loads any `.tres` ZoneNode resources from `res://data/zones/`), and calls `ServiceLocator.register_management_service()`.
   - Implements `process_management_tick()`: iterates `_world_nodes` and calls `node.process_management_tick()` — exactly what `ManagementAPI._on_day_changed()` does now.
   - Implements `get_save_snapshot() -> Dictionary` for the save system.
   - Exposes the `populants_starving` signal for the coordinator to intercept.

---

### Phase 3: UICoordinator & StandardHUD
Replace the old `HUD.gd` flat approach with a proper UI state machine.

1. Create `src/feudal-age/scenes/ui/UICoordinator.tscn` (CanvasLayer):
   - Children: `StandardHUD` (Control), `ZoneInspectionMenu` (PanelContainer).
2. Create `src/feudal-age/scripts/ui/UICoordinator.gd`:
   - `enum UIState { HUD_ONLY, INSPECTING_NODE, MODAL_MENU }`.
   - `change_ui_state(new_state)`: hides all panels then shows the correct ones via a `match` block.
   - `inspect_zone(node_id)`: transitions to `INSPECTING_NODE` and calls `zone_menu.open_inspection_window(node_id)`.
   - `close_menus()`: returns to `HUD_ONLY`.
3. Create `src/feudal-age/scripts/ui/StandardHUD.gd`:
   - Migrates the existing display logic from `HUD.gd` (gold, prestige, season, messages) preserving all `EventBus` connections.
   - Adds a `Day: N` label connected to `EventBus.day_changed`.
4. Create `src/feudal-age/scripts/ui/ZoneInspectionMenu.gd`:
   - `open_inspection_window(node_id)`: queries `ServiceLocator.get_management_service().get_node_inspection_data()` and populates labels using `%UniqueNameLinks`.
   - Displays: Node Name, Tier, Timber stock, Berries, Mushrooms, Worker count, Canopy density.
   - "Establish Camp" button wired to `ManagementAPI.establish_camp()`.

---

### Phase 4: InputRouter
Decouple input from individual nodes and route it through a single gatekeeper.

1. Create `src/feudal-age/scripts/InputRouter.gd`:
   - `@onready var ui_coordinator: UICoordinator = $"../UI"`.
   - `_unhandled_input(event)`: checks for `force_quit`, then dispatches to one of three subroutines based on `UICoordinator.current_ui_state`.
   - `_process_modal_menu_inputs()`: Escape → `close_menus()`.
   - `_process_inspection_view_inputs()`: Escape → `close_menus()`; left-click → re-evaluate spatial raycast.
   - `_process_standard_gameplay_inputs()`: Escape → `MODAL_MENU`; left-click → `_evaluate_spatial_raycast_selection()`.
   - `_evaluate_spatial_raycast_selection()`: casts a ray from the camera, if it hits a `ZoneAnchor3D` calls `ui_coordinator.inspect_zone(zone_anchor.zone_node.node_id)`.
2. Add `interact_select` and `force_quit` actions to `project.godot` InputMap.

---

### Phase 5: ZoneInspectionMenu — Hover HUD
Implement the floating zone inspection tooltip on hover (agreed in management module plan).

1. Extend `InputRouter._process_environmental_selection_inputs()` to also handle mouse-motion events:
   - On `InputEventMouseMotion`, cast a ray and check if the hit object is a `ZoneAnchor3D`.
   - If yes: call `UICoordinator.show_zone_hover_tooltip(node_id, screen_position)`.
   - If no: call `UICoordinator.hide_zone_hover_tooltip()`.
2. Add a lightweight `ZoneHoverTooltip` (PanelContainer) to the UI hierarchy:
   - Follows `screen_position` via `offset_left/top`.
   - Shows: Name, Tier, Timber, Berries, Mushrooms, Worker count.
   - No buttons — read-only snapshot.

---

### Phase 6: SaveGameFile Resource & Persistence Stubs
Lay the groundwork for the save system.

1. Create `src/feudal-age/scripts/resources/SaveGameFile.gd`:
   - Extends `Resource`.
   - Properties: `meta_day_count: int`, `meta_save_time: String`, `management_snapshot: Dictionary`, `social_snapshot: Dictionary`.
2. Implement `execute_session_save()` and `execute_session_load()` stubs in `GameCoordinator.gd`.

---

## Verification Strategy

After each phase, run:
```powershell
godot --path ./src/feudal-age/ --headless --quit
```

> [!NOTE]
> `GameManager.gd` will be kept as an autoload throughout implementation but progressively stripped of responsibilities migrated to `GameCoordinator`. It will be a stub by the end of Phase 3 and can be removed once all consumers have migrated.
