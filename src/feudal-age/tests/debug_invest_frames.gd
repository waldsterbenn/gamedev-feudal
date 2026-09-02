extends SceneTree
# Framed diagnostic: patch ManagementAPI registration via polling + check for _ready errors per NPC.
var _gc: Node = null
var _frames: int = 0
var _prev := {}
var _seen_frames := {}

func _process(_d: float) -> bool:
	if _gc == null:
		var s: PackedScene = load("res://scenes/gamecoordinator/GameCoordinator.tscn")
		_gc = s.instantiate()
		root.add_child(_gc)
		return false
	_frames += 1
	var api: Node = root.get_node("ServiceLocator").management_api
	# Track calls by watching _registered_populants mutation timing, per frame
	var snap := {}
	for id in api._registered_populants:
		snap[id] = api._registered_populants[id].get_instance_id()
	if snap != _prev:
		print("frame ", _frames, " registration snapshot: ", snap)
		_prev = snap
	# Check errors: look for orphaned/invisible nodes with component script
	if _frames in [1,2,3,4,5,6,7,8,9,10]:
		var n = 0
		for c in root.find_children("*", "ManagementPopulantComponent", true, false):
			n += 1
		if not _seen_frames.has(_frames):
			_seen_frames[_frames] = n
			print("frame ", _frames, ": visible comp count=", n, " registered=", api._registered_populants.size())
	if _frames == 12:
		# check npc physics body nodes for children count
		for npc in root.find_children("*", "CharacterBody3D", true, false):
			if npc.get_parent().name == "NPCContainer":
				var comp = npc.get_node_or_null("ManagementPopulantComponent")
				print("npc=", npc.name, " id=", npc.id, " comp=", comp.character_id if comp else "none",
					" comp_ready=", comp.is_node_ready() if comp else "n/a",
					" comp_inside=", comp.is_inside_tree() if comp else "n/a")
		quit(0)
		return true
	return false
