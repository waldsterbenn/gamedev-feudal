extends PlayerStateBase

func physics_update(_delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if player and not input_dir:
		state_machine.change_state_by_path("Idle")
		return
	if player and Input.is_action_just_pressed("jump") and player.is_on_floor():
		state_machine.change_state_by_path("Jumping")
