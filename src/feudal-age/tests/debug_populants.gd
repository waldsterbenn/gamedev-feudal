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
	if _frames < 10:
		return false
	var api: Node = root.get_node("ServiceLocator").management_api
	print("registered: ", api._registered_populants.size())
	for id in api._registered_populants:
		var c: Node = api._registered_populants[id]
		print("  id=", id, " qual=", c.qualification_profile, " lord=", c.serving_lord_id, " node=", c.assigned_node_id, " path=", c.get_parent().get_path())
	var npcs := root.find_children("*", "NPC", true, false)
	print("NPCs found: ", npcs.size())
	for n in npcs:
		var comp: Node = n.get_node_or_null("ManagementPopulantComponent")
		if comp:
			print("  npc id=", n.id, " comp char_id=", comp.character_id, " qual=", comp.qualification_profile, " in_tree=", comp.is_inside_tree(), " ready=", comp.is_node_ready())
		else:
			print("  npc id=", n.id, " NO COMP")
	quit(0)
	return true
