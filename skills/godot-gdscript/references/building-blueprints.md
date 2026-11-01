# Building `.tres` blueprints + `.tscn` scene convention — reference

Used by task #53 (`docs/wayfinder/findings/08-create-building-blueprints.md`). Keeps the pattern reproducible without re-inventing the format.

## `.tres` format (`BuildingData` resource)

Always use `format=3` and include the script `ExtResource`:

```
[gd_resource type="Resource" script_class="BuildingData" load_steps=2 format=3 uid="uid://bp_name_01"]
[ext_resource type="Script" path="res://scripts/management/resources/BuildingData.gd" id="1_script"]
[resource]
script = ExtResource("1_script")
building_id = "name"
display_name = "Display Name"
build_cost = {"Timber": 25}
total_work_required = 50.0
max_jobs = 2
job_type = "forager"
visual_scene_path = "res://scenes/world/buildings/name.tscn"
```

Rules:
- `building_id` (String) matches the `.tscn` scene file stem: `scenes/world/buildings/<id>.tscn`.
- `build_cost` is a `Dictionary` (key = resource name, value = int).
- `total_work_required` is float; `max_jobs` is int; `job_type` is the string key used by `ZoneNode.get_total_job_slots()`.
- `visual_scene_path` points at the in-world building scene spawned at ORDER time (not completion) — keep it in sync with `building_id`.
- Always validate new `.tres` files with `python validate_godot.py <path>`; `.uid` file warnings are expected.

## `.tscn` building scene convention

Root is `Node3D` named after the building (same as `.tscn` stem), with the `ConstructionVisual3D` script attached (`res://scripts/world/construction_visual_3d.gd`) and `atlas_material` pointing at the model's material `.tres`. Children:

- `Model` — the imported FBX PackedScene instance (probe the AABB first and scale the node so the footprint matches collision; see SKILL.md "Probe scale and shape").
- `StaticBody3D` named `PhysicsBody` (collision layer = 1 environment, mask = 0).
- `CollisionShape3D` inside `PhysicsBody` with a primitive `BoxShape3D` sized to the visual footprint.

The root script drives construction feedback: ghost (small, translucent) at order → grows + solidifies with `construction_progress` → opaque at completion. Keep the script generic — per-building identity lives in the `.tres` + scene composition, not in bespoke code.

## Integration points

- `zone_inspection_menu.gd`: the build button (or keyboard `B` via the `blueprint_order_requested` signal) applies the PANEL's selected blueprint and calls `api.order_building()` — the keyboard never picks the blueprint itself.
- `ZoneAnchor3D.gd`: on `building_ordered` (order time, not completion), loads `visual_scene_path`, instantiates, calls `setup(building)` to bind progress, and arranges buildings in a circle around the anchor. Nothing spawns on `building_completed` — the visual already exists.
- `ManagementAPI.gd`: `order_building()` deducts available resources (order-anytime), records `allocated_construction_resources`, and emits the shortfall toast; `adjust_job_target()` is the ONLY worker-assignment writer. `ZoneNode.process_management_tick()` handles construction progress and production.
- `keyboard_zone_selector.gd`: emits `zone_selected` + `blueprint_order_requested` / `blueprint_cycle_requested`; modifier keys (`G`/`Shift+G`, `F`/`Shift+F`) call `api.adjust_job_target()` with ±1.

This convention separates data (`.tres`) from logic (`ManagementAPI`/`ZoneNode`) and representation (`.tscn`), matching the component-based architecture rule.
