@tool
extends Node3D

@onready var terrain: Terrain3D = $Terrain3D
@onready var height_generator: Node = $HeightMapGenerator
@onready var texture_generator: Node = $TextureMapGenerator

@export_tool_button("Generate Terrain", "Callable") var generate_button = generate_terrain

func _ready() -> void:
	pass

func generate_terrain() -> void:
	if height_generator:
		height_generator.generate()
	else:
		push_error("TerrainManager: HeightMapGenerator child not found.")
	
	if texture_generator:
		texture_generator.generate()
