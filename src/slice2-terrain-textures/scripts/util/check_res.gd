# Debug script to check height.res
extends SceneTree

func _init():
	var path = "res://terrain_data/height.res"
	if not FileAccess.file_exists(path):
		print("File does not exist: ", path)
		quit()
	
	var res = ResourceLoader.load(path)
	if res == null:
		print("Failed to load resource: ", path)
	else:
		print("Loaded resource: ", res)
		if res is Image:
			print("It is an Image! Size: ", res.get_width(), "x", res.get_height(), " Format: ", res.get_format())
		else:
			print("It is NOT an Image. It is a ", res.get_class())
	
	quit()
