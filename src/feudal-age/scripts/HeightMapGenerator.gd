@tool
extends Node

## Procedural Heightmap Generator for Terrain3D
## Generates noise-based terrain and applies it to the parent TerrainManager.

@export_group("Height Settings")
@export var min_height: float = 0.0
@export var max_height: float = 150.0

@export_group("Noise Settings")
@export_range(0.0, 0.005, 0.00001) var frequency: float = 0.001:
	set(value):
		frequency = value
		if noise:
			noise.frequency = frequency

@export var noise_scale: float = 1.0

@export var noise_seed: int = 1:
	set(value):
		noise_seed = value
		if noise:
			noise.seed = noise_seed

@export_tool_button("Generate Heightmap", "Callable") var generate_button = generate

var noise: FastNoiseLite

func _ready() -> void:
	_setup_noise()

func _setup_noise() -> void:
	noise = FastNoiseLite.new()
	noise.frequency = frequency
	noise.seed = noise_seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN

## Main generation function. Can be called from Inspector or API.
func generate() -> void:
	var terrain_manager = get_parent()
	if not terrain_manager or not terrain_manager.has_node("Terrain3D"):
		push_error("HeightMapGenerator: Parent must be TerrainManager with a Terrain3D child.")
		return
	
	var terrain: Terrain3D = terrain_manager.get_node("Terrain3D")
	if not terrain.data:
		push_error("HeightMapGenerator: Terrain3D data not initialized.")
		return

	print("HeightMapGenerator: Starting generation (Frequency: ", frequency, ", Scale: ", noise_scale, ")...")
	
	if not noise:
		_setup_noise()
	
	# 2048x2048 vertices at 1.0 spacing = 2048m x 2048m
	var size: int = 2048
	var img: Image = Image.create_empty(size, size, false, Image.FORMAT_RF)
	
	var actual_min := 99999.0
	var actual_max := -99999.0

	for x in size:
		for y in size:
			# Apply scale by dividing coordinates before sampling
			var n_val = noise.get_noise_2d(x / noise_scale, y / noise_scale)
			var normalized_val = (n_val + 1.0) / 2.0
			var final_height = lerp(min_height, max_height, normalized_val)
			img.set_pixel(x, y, Color(final_height, 0, 0, 1))
			
			actual_min = min(actual_min, final_height)
			actual_max = max(actual_max, final_height)
	
	# Import the generated image into Terrain3D
	# [height_map, control_map, color_map]
	# Center a 2048m area at (0,0,0) requires top-left offset of -1024m
	var offset = Vector3(-1024, 0, -1024)
	
	terrain.data.import_images([img, null, null], offset, 0.0, 1.0)
	
	print("HeightMapGenerator: Generation complete.")
	print(" - Area Covered: 512m x 512m")
	print(" - Height Range: [", actual_min, ", ", actual_max, "]")
	print(" - World Offset: ", offset)
