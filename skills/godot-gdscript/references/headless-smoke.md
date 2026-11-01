# Headless smoke / SceneTree (`--script`) — reference

Use this pattern for any headless verification or data-layer probe.

## Why `_init()` fails for scene loads

In `extends SceneTree` (`godot --script ...`), autoload globals (`ServiceLocator`, `EventBus`) are not yet registered as GDScript identifiers when `_init()` runs, so any scene that contains scripts referencing them compiles-fails. Load scenes inside `_process()` (after the first frame, once autoloads are instantiated) and fetch autoloads from the tree root:

```gdscript
func _process(_delta: float) -> bool:
    if _gc == null:
        var s: PackedScene = load("res://scenes/gamecoordinator/GameCoordinator.tscn")
        _gc = s.instantiate()
        root.add_child(_gc)
        return false  # let _ready() chains complete
```

```gdscript
var service_locator: Node = root.get_node_or_null("ServiceLocator")
var api: Node = service_locator.get_management_service() if service_locator else null
```

## Driving the data layer deterministically

For reproducible assertions (e.g. `ManagementAPI.establish_camp()` + `assign_populant_to_node()` + manual tick loop):

1. Wait `>= 5` frames after `_gc` instantiation so `WorldInitializer._ready()` and `ManagementPopulantComponent._ready()` complete.
2. Read `api._registered_populants` to verify registrations (expect all IDs 1–N, not only key `0`).
3. Re-issue `recruit_populant_to_faction()` and `assign_populant_to_node()` through the public API (boot-time assignment may fail because component `_ready()` hasn't fired yet; the `NPC.gd` fix sets `character_id` before `add_child()`, so this is mainly defensive).
4. Set `manual_job_postings` on the zone (`{"woodcutter": 1}`) to simulate completed-building job slots — without `.tres` blueprints + `.tscn` scenes, no completed buildings exist, so no `woodcutter` slots are created.
5. Stop the GC's `Timer` (`for child in _gc.get_children(): if child is Timer: child.stop()`), then issue ticks manually via `_on_simulation_tick_elapsed()` rather than relying on real-time delays.
6. Assert `zone.stockpile.get("Timber", 0) > 0` after `>= 3` ticks; optionally assert `canopy_density < 1.0` for ecological-observable verification.
7. Call `quit(0)` on PASS, `quit(1)` on FAIL.

## Reusable repro scripts (kept in-tree, not temporary)

- `tests/smoke_slice.gd` — full slice smoke (`PASS` / exit 0).
- `tests/debug_populants.gd` — dumps registered count, qualifications, IDs, node assignments.
- `tests/debug_step.gd` — frame-level instrumentation of registration events.
- `tests/debug_invest_reg.gd` / `tests/debug_invest_cls.gd` / `tests/debug_invest_frames.gd` — narrow probes for future registration/debug work.

These are evidence files, not throwaway artifacts. Do not delete them.
