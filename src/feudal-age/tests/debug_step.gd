extends SceneTree
var _gc: Node = null
var _frames: int = 0
var _registered_at: int = -1
func _process(_d: float) -> bool:
	if _gc == null:
		var s: PackedScene = load("res://scenes/gamecoordinator/GameCoordinator.tscn")
		_gc = s.instantiate()
		root.add_child(_gc)
		return false
	_frames += 1
	# instrument: patch register calls
	var api: Node = root.get_node("ServiceLocator").management_api
	var count: int = api._registered_populants.size() if api else -1
	if count != _registered_at:
		print("DEBUG frame ", _frames, " registered count=", count)
		_registered_at = count
	# check NPC._ready timing
	if _frames == 2:
		for c in root.find_children("*", "ManagementPopulantComponent", true, false):
			var npc: Node = c.get_parent()
			print("DEBUG npc ", npc.name, " ready=", npc.is_node_ready(), " comp char_id=", c.character_id)
	if _frames > 300:
		quit(0)
		return true
	return false
