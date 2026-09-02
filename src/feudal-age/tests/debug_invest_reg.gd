extends SceneTree
var _gc: Node = null
var _frames: int = 0
var _seen := {}

func _process(_d: float) -> bool:
	if _gc == null:
		var s: PackedScene = load("res://scenes/gamecoordinator/GameCoordinator.tscn")
		_gc = s.instantiate()
		root.add_child(_gc)
		return false
	_frames += 1
	var api: Node = root.get_node("ServiceLocator").management_api
	var comps := root.find_children("*", "ManagementPopulantComponent", true, false)
	for c in comps:
		var key: String = str(c.get_instance_id())
		if not _seen.has(key):
			_seen[key] = { "frame": _frames, "id": c.character_id, "qual": c.qualification_profile,
				"parent": str(c.get_parent().get_path()), "ready": c.is_node_ready() }
			print("NEW COMP frame=", _frames, " inst=", c.get_instance_id(), " char_id=", c.character_id,
				" qual=", c.qualification_profile, " parent=", c.get_parent().get_path(),
				" ready=", c.is_node_ready(), " in_tree=", c.is_inside_tree(), " script=", c.get_script())
	# registrations snapshot
	if _frames in [2, 5, 10, 30, 60]:
		print("frame ", _frames, " registered=", api._registered_populants.size(), " keys=", api._registered_populants.keys())
	# after 8 registrations happened, dump them
	if api._registered_populants.size() >= 8 and not _seen.has("dumped"):
		_seen["dumped"] = true
		print("FULL DUMP at frame ", _frames)
		for id in api._registered_populants:
			var c = api._registered_populants[id]
			print("  reg id=", id, " inst=", c.get_instance_id(), " parent=", c.get_parent().get_path(), " ready=", c.is_node_ready())
	if _frames > 90:
		print("END registered=", api._registered_populants.size())
		quit(0)
		return true
	return false
