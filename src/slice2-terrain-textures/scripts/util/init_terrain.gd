# Simple script to initialize HTerrain data
extends SceneTree

func _init():
	var hterrain_data_script = load("res://addons/zylann.hterrain/hterrain_data.gd")
	var data = hterrain_data_script.new()
	data.resize(513)
	
	# Compute vertical bounds (private method)
	if data.has_method("_update_all_vertical_bounds"):
		data.call("_update_all_vertical_bounds")
	
	var err = data.save_data("res://terrain_data")
	if err:
		print("Terrain data initialized in res://terrain_data")
	else:
		print("Failed to save terrain data")
		
	# Verify
	var errors = []
	# HTerrainData._validate is a private method usually, let's see if we can check it
	# Actually, get_all_heights will trigger the assertion if it's broken
	# We'll just trust the save for now.
	
	quit()
