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
```

Rules:
- `building_id` (String) matches the `.tscn` scene file stem: `scenes/world/buildings/<id>.tscn`.
- `build_cost` is a `Dictionary` (key = resource name, value = int).
- `total_work_required` is float; `max_jobs` is int; `job_type` is the string key used by `ZoneNode.get_total_job_slots()`.
- Always validate new `.tres` files with `python validate_godot.py <path>`; `.uid` file warnings are expected.

## `.tscn` primitive scene convention

Root is `Node3D` named after the building (same as `.tscn` stem). Children:

- `MeshInstance3D` named `VisualMesh` (primitive `BoxMesh` or `CylinderMesh`, simple `StandardMaterial3D` albedo color).
- `StaticBody3D` named `PhysicsBody` (collision layer = 1 environment, mask = 0).
- `CollisionShape3D` inside `PhysicsBody` with a primitive `BoxShape3D` or `CylinderShape3D`.

No GDScript script on the scene root — buildings are data-driven instances (`BuildingInstance`) created by `ZoneAnchor3D._on_building_completed()`. The `.tscn` provides only the visual + collision representation.

Always validate `.tscn` with `validate_godot.py`. Ensure `load_steps` equals the number of `ext_resource` + `sub_resource` entries + 1.

## Integration points

- `zone_inspection_menu.gd`: the build button loads `res://data/blueprints/<name>.tres` (or scans the directory) and calls `api.order_building()`.
- `ZoneAnchor3D.gd`: on `building_completed` signal, loads `res://scenes/world/buildings/<building_id>.tscn` and instantiates + positions.
- `ManagementAPI.gd`: `order_building()` creates a `BuildingInstance` with `.blueprint = <BuildingData resource>`, `.is_completed = false`, `.construction_progress = 0.0`, and appends to `node.buildings`. `ZoneNode.process_management_tick()` handles construction progress (`_process_construction_progress`) and production (`_execute_production_and_labor`) based on completed buildings' `.blueprint.job_type`.

This convention separates data (`.tres`) from logic (`ManagementAPI`/`ZoneNode`) and representation (`.tscn`), matching the component-based architecture rule.
