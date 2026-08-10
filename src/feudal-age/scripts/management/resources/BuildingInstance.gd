extends Resource
class_name BuildingInstance

@export var blueprint: BuildingData
@export var is_completed: bool = false
@export var construction_progress: float = 0.0 
@export var integrity: float = 1.0             
@export var assigned_worker_ids: Array[int] = []
