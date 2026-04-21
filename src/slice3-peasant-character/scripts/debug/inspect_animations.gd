extends SceneTree

func _init() -> void:
	var scene: PackedScene = load("res://assets/characters/peasant/SK_Character_Human_Peasant.fbx")
	var instance: Node = scene.instantiate()
	print("=== PEASANT FBX ===")
	_inspect(instance, 0)
	instance.queue_free()
	
	var anim_scene: PackedScene = load("res://assets/characters/peasant/Characters.fbx")
	if anim_scene:
		var anim_instance: Node = anim_scene.instantiate()
		print("\n=== CHARACTERS FBX (Unity) ===")
		_inspect(anim_instance, 0)
		anim_instance.queue_free()
	else:
		print("\nCharacters.fbx not found or not imported")
	quit()

func _inspect(node: Node, depth: int) -> void:
	var indent: String = "  ".repeat(depth)
	print(indent + node.name + " (" + node.get_class() + ")")
	if node is AnimationPlayer:
		var anim_player: AnimationPlayer = node as AnimationPlayer
		var anims: PackedStringArray = anim_player.get_animation_list()
		print(indent + "  Animations [" + str(anims.size()) + "]: " + str(anims))
		for anim_name in anims:
			var anim: Animation = anim_player.get_animation(anim_name)
			print(indent + "    '" + anim_name + "': length=" + str(anim.length) + ", tracks=" + str(anim.get_track_count()))
			for i in range(min(anim.get_track_count(), 5)):
				print(indent + "      track " + str(i) + ": " + anim.track_get_path(i).get_concatenated_names() + " (" + str(anim.track_get_key_count(i)) + " keys)")
			if anim.get_track_count() > 5:
				print(indent + "      ... and " + str(anim.get_track_count() - 5) + " more tracks")
	if node is Skeleton3D:
		var skel: Skeleton3D = node as Skeleton3D
		print(indent + "  Bones: " + str(skel.get_bone_count()))
	for child in node.get_children():
		_inspect(child, depth + 1)
