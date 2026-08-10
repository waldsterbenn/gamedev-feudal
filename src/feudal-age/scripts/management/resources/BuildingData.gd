extends Resource
class_name BuildingData

@export var building_id: String        # e.g., "charcoal_stack", "covered_work_area", "forager_post"
@export var display_name: String
@export var build_cost: Dictionary = {"Timber": 25}
@export var total_work_required: float = 50.0 
@export var max_jobs: int = 2
@export var job_type: String           
