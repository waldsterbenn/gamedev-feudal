---
status: open
type: task
blocked-by: [06-first-headless-boot]
---

# Create minimal building `.tres` blueprints

## Question

`zone_inspection_menu.gd` references `res://data/blueprints/tent.tres` but it does not exist. We need at least one (preferably three for the slice to feel real) `BuildingData` resources saved to `src/feudal-age/data/blueprints/`.

The decision: which buildings for the slice? Minimal set per the management-module GDD:

| Building | Tier | Cost | Work | Jobs | Source |
|---|---|---|---|---|---|
| Tent | CAMP | Timber: 25 | 50 | 0 (housing) | `management-module-gdd.md` §4 |
| Forager Post | CAMP | Timber: 30 | 60 | 2 foragers | `management-module-gdd.md` §6 |
| Charcoal Woodstack | CAMP | Timber: 40 | 80 | 2 woodcutters | `management-module-gdd.md` §4 |

This is a **task** (not a decision): we know exactly what to build, we just have to do it.

The work:
1. Create the `data/blueprints/` directory.
2. Create three `.tres` files using `BuildingData` resource.
3. Update `zone_inspection_menu.gd`'s build-button handler to use a list of available blueprints (or pick one — for the slice, building a tent first is simplest because it has 0 jobs so it just tests the construction path).
4. Create `res://scenes/world/buildings/tent.tscn` (a minimal cube scene with collision) since `ZoneAnchor3D._on_building_completed` instantiates `res://scenes/world/buildings/<building_id>.tscn`.
5. Same for `forager_post.tscn` and `charcoal_stack.tscn`.

Output target: working build + findings at `docs/wayfinder/findings/08-create-building-blueprints.md`.