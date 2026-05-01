extends StateNode

func enter(_data: Dictionary = {}) -> void:
	pass

func physics_update(_delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if input_dir:
		state_machine.change_state_by_path("Patrol")
	else:
		state_machine.change_state_by_path("Idle")
