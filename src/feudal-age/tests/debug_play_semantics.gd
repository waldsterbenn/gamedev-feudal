extends SceneTree

## Throwaway probe: does play() on the SAME animation restart it, and does
## re-playing update the custom speed? And does get_playing_speed() reflect it?

var _stage: int = 0
var _frames_waited: int = 0
var _scene_root: Node = null
var _ap: AnimationPlayer = null

func _process(_delta: float) -> bool:
	_frames_waited += 1
	match _stage:
		0:
			if _frames_waited < 5:
				return false
			_scene_root = (load("res://scenes/characters/PeasantCharacter.tscn") as PackedScene).instantiate()
			root.add_child(_scene_root)
			_stage = 1
			_frames_waited = 0
		1:
			if _frames_waited < 2:
				return false
			_ap = _scene_root.get_animation_player()
			_ap.play("Walking_A", 0.2, 5.0)
			print("t0 pos=", _ap.current_animation_position, " playing_speed=", _ap.get_playing_speed())
			_stage = 2
			_frames_waited = 0
		2:
			if _frames_waited < 3:
				return false
			var pos_before: float = _ap.current_animation_position
			_ap.play("Walking_A", 0.2, 2.0)
			print("same-name replay: pos_before=", pos_before, " pos_after=", _ap.current_animation_position,
					" playing_speed=", _ap.get_playing_speed())
			_stage = 3
		3:
			if _frames_waited < 3:
				return false
			print("later pos=", _ap.current_animation_position, " playing_speed=", _ap.get_playing_speed())
			quit(0)
	return false