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
- No production logic changed — `NPC.gd`, `ManagementAPI.gd`, `ManagementPopulantComponent.gd` untouched; `tests/smoke_slice.gd` still passes (with #53 testability additions: `Timber=39`, `PASS`).
- `docs/qa/testing-plan.md` (merged in PR #63) documents the gate; this file (`findings/08-...`) fits the wayfinder convention (ticket #53's resolution artifact, linked from the issue).

## Manual game testing (2026-11-01, user-verified)

Player-facing testability additions (PR #64):
- `KeyboardZoneSelector` (`scripts/world/keyboard_zone_selector.gd`, node in `World.tscn`): Tab toggles management mode; number keys `1`–`9` select a zone; `Enter` opens inspection; `B` orders the tent on the selected zone. Emits `EventBus.ui.zone_selected` with the anchor's `zone_node` resource (matching the `UICoordinator._on_zone_selected` contract). Key detection uses edge-tracking (`is_key_pressed` + previous-state map) — Godot 4.7 has no static `Input.is_key_just_pressed()`.
- Zone detection must use `child is ZoneAnchor3D` — `get_class()` returns the engine class (`Area3D`), and `has_node("ZoneNode")` fails because `ZoneNode` is a Resource, not a child node.
- HUD instruction label added to `UICoordinator.tscn` (Tab/Number/Enter/B shortcuts).
- Interaction logging in `zone_inspection_menu.gd`: inspection open/close and build-order attempts print to console.
- Zone 1 (Ironwood Hollow) starts with `initial_stockpile` (Timber 30, Berries 10, Mushrooms 10) seeded in `WorldInitializer.gd` — tent costs 25 Timber, so the player can build on day 1.

Verified in-game by the user: Tab → zones appear; `1`+`Enter` → inspection panel; `B` → `Keyboard Build result: true`, tent mesh spawns in the zone; subsequent `B` correctly refused (`false`) once stockpile drops below cost (economic gate works).

## Dependencies / next

- Unblocks #54 (first loop closure) — the loop-closure prototype needs the `.tres` files and scenes to call `api.order_building()` and observe `ZoneAnchor3D._on_building_completed()`.
- Does NOT implement the interior job-slot logic (that is #54's work) — this ticket stops at producing the artifacts, per the wayfinder task convention (does rather than decides, earns its place by unblocking).
