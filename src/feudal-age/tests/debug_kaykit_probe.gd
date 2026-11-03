extends SceneTree

## Probe: inspect imported KayKit GLBs (structure, animations, track paths, AABB scale)
## for issue #78 (NPC state-driven animation). Throwaway debug instrument.

func _process(_delta: float) -> bool:
	_inspect_rig()
	quit(0)
	return false

func _inspect_rig() -> void:
	var paths: Array[String] = [
		"res://assets/characters/kaykit/Rogue_Hooded.glb",
		"res://assets/characters/kaykit/Rig_Medium_General.glb",
		"res://assets/characters/kaykit/Rig_Medium_MovementBasic.glb",
	]
	for p in paths:
		print("===== ", p)
		var scene: PackedScene = load(p)
		if scene == null:
			print("  LOAD FAILED")
			continue
		var inst: Node = scene.instantiate()
		_dump(inst, 0)
		inst.queue_free()

func _dump(node: Node, depth: int) -> void:
	var indent: String = "  ".repeat(depth)
	var extra: String = ""
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		var aabb: AABB = mi.mesh.get_aabb() if mi.mesh else AABB()
		extra = " aabb_pos=%s aabb_size=%s" % [aabb.position, aabb.size]
	if node is AnimationPlayer:
		var ap := node as AnimationPlayer
		extra = " root_node=%s anims=%s" % [ap.root_node, str(ap.get_animation_list())]
		for anim_name in ap.get_animation_list():
			var anim: Animation = ap.get_animation(anim_name)
			var track0: String = anim.track_get_path(0) if anim.get_track_count() > 0 else "-"
			print(indent + "  '" + anim_name + "': len=" + str(anim.length) + " tracks=" + str(anim.get_track_count()) + " t0=" + str(track0) + " loop=" + str(anim.loop_mode))
	print(indent + node.name + " (" + node.get_class() + ")" + extra)
	for child in node.get_children():
		_dump(child, depth + 1)
