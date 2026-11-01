extends Resource
class_name BuildingData

@export var building_id: String        # e.g., "lumber_camp", "forager_hut", "tent"
@export var display_name: String
@export var build_cost: Dictionary = {"Timber": 25}
@export var total_work_required: float = 50.0
@export var max_jobs: int = 2
@export var job_type: String
@export var visual_scene_path: String = ""   # primitive scene spawned in-world on order (#70)
## Per-resource storage caps this building adds to the zone (stacking).
## Empty = adds no cap. Production halts per-resource at cap (#85).
@export var storage_caps: Dictionary = {}
## Housing: how many residents this building can hold (Tent = 4). 0 = not
## housing. Zone resident cap = sum over completed housing buildings (#85).
@export var housing_capacity: int = 0
