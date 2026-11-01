# Findings — Create Building Blueprints (#53)

**Task completed 2026-09-02.** AFK (manual work, no decision) — produces the artifacts the loop-closure (#54) prototype depends on.

## What was built

### `.tres` blueprints (`data/blueprints/`)

| File | Building | Tier | Cost | Work | Jobs | Job Type |
|---|---|---|---|---|---|---|
| `tent.tres` | Tent | CAMP | Timber: 25 | 50 | 0 | housing |
| `forager_post.tres` | Forager Post | CAMP | Timber: 30 | 60 | 2 | forager |
| `charcoal_stack.tres` | Charcoal Woodstack | CAMP | Timber: 40 | 80 | 2 | woodcutter |

All three pass `validate_godot.py` (`Resource: ... PASSED`). `.uid` warnings are normal — Godot creates them on first open.

### Scene instances (`scenes/world/buildings/`)

Three minimal `.tscn` scenes (format=3, primitive BoxShape3D/CylinderShape3D, layer 1 environment, mask 0): `tent.tscn`, `forager_post.tscn`, `charcoal_stack.tscn`. Each has a root `Node3D`, `MeshInstance3D` (`VisualMesh`), and `StaticBody3D` (`PhysicsBody`) with a primitive `CollisionShape3D`. No God scripts needed (pure data + primitives, matching the architecture's component-based pattern for buildings).

### Updated handler

`zone_inspection_menu.gd`: build-button handler now explicitly selects `tent.tres` (simplest — 0 jobs, just exercises the `ManagementAPI.order_building()` → `ZoneNode.buildings` → `ZoneAnchor3D._on_building_completed()` → scene instantiate path). The other blueprints are ready for future extension once #54 (loop closure) needs production jobs.

## Validation
- `.tres`: `validate_godot.py` — PASSED (3 files)
- `.tscn`: `validate_godot.py` — PASSED (header format correct; `.uid` warning is expected)
- No production logic changed — `NPC.gd`, `ManagementAPI.gd`, `ManagementPopulantComponent.gd` untouched; `tests/smoke_slice.gd` still passes on master (`Timber=9`, `PASS`).
- `docs/qa/testing-plan.md` (merged in PR #63) documents the gate; this file (`findings/08-...`) fits the wayfinder convention (ticket #53's resolution artifact, linked from the issue).

## Dependencies / next

- Unblocks #54 (first loop closure) — the loop-closure prototype needs the `.tres` files and scenes to call `api.order_building()` and observe `ZoneAnchor3D._on_building_completed()`.
- Does NOT implement the interior job-slot logic (that is #54's work) — this ticket stops at producing the artifacts, per the wayfinder task convention (does rather than decides, earns its place by unblocking).
