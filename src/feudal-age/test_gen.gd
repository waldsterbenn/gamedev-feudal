extends SceneTree

func _init() -> void:
	var scene_path = "res://scenes/TerrainManager.tscn"
	var scene: PackedScene = load(scene_path)
	if not scene:
		printerr("Test: Could not load scene.")
		quit(1)
		return
		
	var root: Node = scene.instantiate()
	var generator: TextureMapGenerator = root.find_child("TextureMapGenerator", true, false)
	var terrain: Terrain3D = root.find_child("Terrain3D", true, false)
	
	if not generator or not terrain:
		printerr("Test: Generator or Terrain not found.")
		quit(1)
		return

	# Set up a fake environment if needed, but here we just want to run the logic
	print("Test: Triggering generation...")
	generator.generate()
	
	# Inspect the results
	var active_regions = terrain.data.get_regions_active()
	if active_regions.is_empty():
		print("Test: No active regions found!")
	else:
		var region = active_regions[0]
		var ctrl_img = region.get_map(Terrain3DRegion.TYPE_CONTROL)
		var pixel = ctrl_img.get_pixel(0, 0)
		var pixel_uint = Terrain3DUtil.as_uint(pixel.r)
		
		print("Test: Region size: ", region.region_size)
		print("Test: Sample Pixel (0,0) Uint: ", pixel_uint)
		print("Test: Decoded Base ID: ", Terrain3DUtil.get_base(pixel_uint))
		print("Test: Decoded Blend: ", Terrain3DUtil.get_blend(pixel_uint))
		
	root.free()
	quit()
