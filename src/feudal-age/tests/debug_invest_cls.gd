extends SceneTree
var _gc: Node = null
var _frames: int = 0

func _process(_d: float) -> bool:
	if _gc == null:
		var s: PackedScene = load("res://scenes/gamecoordinator/GameCoordinator.tscn")
		_gc = s.instantiate()
		root.add_child(_gc)
		return false
	_frames += 1
	if _frames == 2:
		var comps := root.find_children("*", "ManagementPopulantComponent", true, false)
		print("COMP COUNT at frame 2: ", comps.size())
		for c in comps:
			var npc: Node = c.get_parent()
			var s = npc.get_script()
			print("char_id=", c.character_id, " parent_name=", npc.name,
				" parent_script=", s.resource_path if s else "<none>",
				" parent_class=", npc.get_class())
		quit(0)
		return true
	return false
