@tool
extends Node3D

@onready var terrain: Terrain3D = $Terrain3D
@onready var height_generator: Node = $HeightMapGenerator
@onready var texture_generator: Node = $TextureMapGenerator

@export_tool_button("Generate Terrain", "Callable") var generate_button = generate_terrain

func _ready() -> void:
	if not Engine.is_editor_hint():
		ServiceLocator.register_terrain_service(self)

func generate_terrain() -> void:
	if height_generator:
		height_generator.generate()
	else:
		push_error("TerrainManager: HeightMapGenerator child not found.")
	
	if texture_generator:
		texture_generator.generate()

## Returns the terrain height at the given global position, or NAN if unavailable.
func get_height(global_position: Vector3) -> float:
	if terrain and terrain.data:
		return terrain.data.get_height(global_position)
	return NAN

## Returns the terrain normal at the given global position.
func get_normal(global_position: Vector3) -> Vector3:
	if terrain and terrain.data:
		return terrain.data.get_normal(global_position)
	return Vector3.UP
