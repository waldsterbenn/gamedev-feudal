extends SceneTree

## Smoke test for issue #78: state-driven NPC + player animation.
## Verifies the CharacterAnimationComponent merges the KayKit clip libraries
## onto the character skeletons and that state changes drive the expected clips.
## Player note: states self-transition on missing input headlessly (Moving -> Idle),
## so player clip assertions run synchronously right after the state change.

var _npc: Node = null
var _npc_visuals: Node = null
var _player: Node = null
var _player_visuals: Node = null
var _frames_waited: int = 0
var _stage: int = 0
var _failures: Array[String] = []

func _process(_delta: float) -> bool:
	_frames_waited += 1
	match _stage:
		0:
			if _frames_waited < 5:
				return false
			_stage = 1
			_frames_waited = 0
			var scene: PackedScene = load("res://scenes/characters/NpcPeasant.tscn")
			_npc = scene.instantiate()
			root.add_child(_npc)
		1:
			if _frames_waited < 3:
				return false
			_npc_visuals = _fetch_visuals(_npc)
			_check_merged_libraries(_npc_visuals, "npc")
			# Initial state is Work; WorkState.enter() starts a walk to the first target.
			_expect_clip(_npc_visuals, "Walking_A")
			_npc.state_m.change_state_by_path("Interact")
			_stage = 2
		2:
			_expect_clip(_npc_visuals, "Interact")
			_npc.state_m.change_state_by_path("Idle")
			_stage = 3
			_frames_waited = 0
		3:
			if _frames_waited < 2:
				return false
			_expect_clip(_npc_visuals, "Idle_A")
			_npc.queue_free()
			# Player: state machine must drive clips too (Idle/Moving/Jumping)
			var player_scene: PackedScene = load("res://scenes/player/Player.tscn")
			_player = player_scene.instantiate()
			root.add_child(_player)
			_stage = 4
			_frames_waited = 0
		4:
			if _frames_waited < 3:
				return false
			_player_visuals = _fetch_visuals(_player)
			_check_merged_libraries(_player_visuals, "player")
			_expect_clip(_player_visuals, "Idle_A")
			# Moving: synchronous check before the state self-transitions back
			_player.state_machine.change_state_by_path("Moving")
			_expect_clip(_player_visuals, "Walking_A")
			# Walking speed sync: Speed_Walk=10.0, clip reference 2.0 -> 5x
			var ap: AnimationPlayer = _player_visuals.get_animation_player()
			_assert(absf(ap.get_playing_speed() - 5.0) < 0.01,
					"player walk playing_speed is 5.0 (got " + str(ap.get_playing_speed()) + ")")
			# Back to idle
			_player.state_machine.change_state_by_path("Idle")
			_expect_clip(_player_visuals, "Idle_A")
			_player.queue_free()
			_finish()
	return false

func _fetch_visuals(owner_node: Node) -> Node:
	var visuals: Node = owner_node.get_node_or_null("PeasantCharacter")
	_assert(visuals != null, "visuals node found on " + owner_node.name)
	return visuals

func _check_merged_libraries(visuals: Node, who: String) -> void:
	var ap: AnimationPlayer = visuals.get_animation_player()
	_assert(ap != null, who + " AnimationPlayer exists on visuals")
	if ap == null:
		return
	for clip in ["Idle_A", "Walking_A", "Running_A", "Use_Item", "Interact"]:
		_assert(ap.has_animation(clip), who + " clip merged: " + clip)
	for clip in ["Idle_A", "Walking_A", "Use_Item"]:
		if ap.has_animation(clip):
			_assert(ap.get_animation(clip).loop_mode == Animation.LOOP_LINEAR,
					who + " clip loops: " + clip)

func _expect_clip(visuals: Node, expected: String) -> void:
	var ap: AnimationPlayer = visuals.get_animation_player()
	_assert(ap.current_animation == expected,
			"current clip is '" + expected + "' (got '" + ap.current_animation + "')")

func _assert(condition: bool, label: String) -> void:
	if condition:
		print("PASS: ", label)
	else:
		_failures.append(label)
		print("FAIL: ", label)

func _finish() -> void:
	if _failures.is_empty():
		print("SMOKE npc_animation: ALL PASS")
		quit(0)
	else:
		print("SMOKE npc_animation: FAILED (%d)" % _failures.size())
		quit(1)