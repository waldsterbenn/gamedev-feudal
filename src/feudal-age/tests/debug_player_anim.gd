extends SceneTree

## Throwaway probe: inspect the player StateMachine's children and their scripts.

var _player: Node = null
var _frames_waited: int = 0
var _stage: int = 0

func _process(_delta: float) -> bool:
	_frames_waited += 1
	match _stage:
		0:
			if _frames_waited < 5:
				return false
			_stage = 1
			_frames_waited = 0
			_player = (load("res://scenes/player/Player.tscn") as PackedScene).instantiate()
			root.add_child(_player)
		1:
			if _frames_waited < 3:
				return false
			_stage = 2
			var sm: StateMachine = _player.state_machine
			print("sm script: ", sm.get_script().resource_path)
			print("sm states dict: ", sm.states)
			for child in sm.get_children():
				var s: Script = child.get_script()
				print("child ", child.name, " script=", (s.resource_path if s else "NONE"),
						" isStateNode=", (child is StateNode))
				if s:
					print("   extends=", s.get_instance_base_type(), " can_instantiate=", s.can_instantiate())
			quit(0)
	return false