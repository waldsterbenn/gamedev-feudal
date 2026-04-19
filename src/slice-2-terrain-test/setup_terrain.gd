@tool
extends SceneTree

func _init():
	var scene_path = "res://Scenes/TerrainTile.tscn"
	var scene = load(scene_path)
	if not scene:
		print("Could not load scene")
		quit()
		return
		
	var root = scene.instantiate()
	if not root:
		print("Could not instantiate scene")
		quit()
		return
		
	# HTerrain node is the root
	var terrain = root
	
	# Create data directory if it doesn't exist
	var data_dir = "res://assets/terrain/data/terrain_data"
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("assets/terrain/data/terrain_data"):
		dir.make_dir_recursive("assets/terrain/data/terrain_data")
		
	# Create HTerrainData
	var HTerrainDataScript = load("res://addons/zylann.hterrain/hterrain_data.gd")
	var data = HTerrainDataScript.new()
	data.resize(513) # Default resolution
	
	# Mark all maps as modified so they get saved
	# HTerrainData uses an internal _maps array of HT_Map objects
	# We need to find where they are and set .modified = true
	# Or just call save_data and see what happens.
	# Actually, resize() might not mark them as modified for saving.
	
	# Let's try to save it
	var success = data.save_data(data_dir)
	print("Save data success: ", success)
	
	if success:
		# The meta file is "data.hterrain" inside the directory
		var data_path = data_dir.path_join("data.hterrain")
		var saved_data = load(data_path)
		if saved_data:
			terrain.set_data(saved_data)
			
			# Pack the scene again
			var packed_scene = PackedScene.new()
			packed_scene.pack(terrain)
			ResourceSaver.save(packed_scene, scene_path)
			print("TerrainTile initialized with data at ", data_path)
		else:
			print("Could not load saved data from ", data_path)
	else:
		print("Failed to save terrain data")
		
	quit()
