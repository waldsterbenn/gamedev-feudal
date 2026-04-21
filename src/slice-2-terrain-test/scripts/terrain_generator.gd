@tool
extends Node

# Preload HTerrainData to access CHANNEL_HEIGHT constant
const HTerrainData = preload("res://addons/zylann.hterrain/hterrain_data.gd")

## The HTerrain node to modify
@export var terrain: Node3D

## Noise generator for the heightmap
@export var noise: FastNoiseLite

## Maximum height of the terrain
@export var height_scale: float = 50.0

## Scale factor for noise coordinates (higher = more zoomed in noise)
@export var noise_scale: float = 1.0

## Press this in the editor to trigger generation
@export var generate: bool = false: set = _set_generate

func _ready() -> void:
	if not noise:
		noise = FastNoiseLite.new()
		noise.seed = randi()
		noise.frequency = 0.01

func _set_generate(val: bool) -> void:
	if val:
		_run_generation()
		generate = false

func _run_generation() -> void:
	if not terrain:
		printerr("TerrainGenerator: No terrain node assigned")
		return
	
	if not terrain.has_method("get_data"):
		printerr("TerrainGenerator: Assigned node is not an HTerrain node")
		return
		
	var data := terrain.call("get_data") as HTerrainData
	if not data:
		printerr("TerrainGenerator: Terrain has no data")
		return
		
	var res: int = data.get_resolution()
	if res <= 0:
		printerr("TerrainGenerator: Terrain data resolution is invalid")
		return
		
	if not noise:
		printerr("TerrainGenerator: No noise assigned")
		return
		
	var height_img: Image = data.get_image(HTerrainData.CHANNEL_HEIGHT)
	if not height_img:
		printerr("TerrainGenerator: Could not get heightmap image")
		return
		
	print("TerrainGenerator: Generating heightmap (", res, "x", res, ")...")
	
	# HTerrain uses FORMAT_RF (32-bit float) for heights
	# Iterating through every pixel to set the noise value
	for y in range(res):
		for x in range(res):
			var v: float = noise.get_noise_2d(float(x) * noise_scale, float(y) * noise_scale) * height_scale
			height_img.set_pixel(x, y, Color(v, 0, 0, 1))
	
	# Notify the data object that a region (the whole map) has changed
	# This triggers internal updates and normal map baking in the editor
	data.notify_region_change(Rect2(0, 0, res, res), HTerrainData.CHANNEL_HEIGHT)
	
	# If running in the editor, attempt to save the data to disk
	if Engine.is_editor_hint():
		var data_path: String = data.resource_path
		if not data_path.is_empty():
			var data_dir: String = data_path.get_base_dir()
			var success: bool = data.save_data(data_dir)
			if success:
				print("TerrainGenerator: Terrain data saved to: ", data_dir)
			else:
				printerr("TerrainGenerator: Failed to save terrain data")
		else:
			print("TerrainGenerator: Terrain data has no resource path. Use 'Terrain > Save' in the editor.")
	
	print("TerrainGenerator: Heightmap generation complete")
