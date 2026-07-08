extends SceneTree

func _init():
	var scene = load("res://scenes/characters/PeasantCharacter.tscn").instantiate()
	# The FBX might need to be in the tree to resolve some things, but usually AABB is available on the mesh
	var model = scene.get_node("Model")
	var skeleton = model.get_node("Root/Skeleton3D")
	var mesh_instance = skeleton.get_child(0)
	
	if mesh_instance is MeshInstance3D:
		var aabb = mesh_instance.get_aabb()
		print("Mesh AABB: ", aabb)
		print("Mesh Height: ", aabb.size.y)
	else:
		print("Could not find MeshInstance3D")
	
	quit()
