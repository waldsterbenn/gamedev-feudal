class_name PlayerJumpState
extends PlayerState
# PlayerJumpState.gd - Jumping behavior

# 1. virtual methods
func enter(data: Dictionary = {}) -> void:
	# The jump action itself is handled in MovementController.move()
	# or we can manually set the velocity here if we want to separate it.
	# For simplicity, we'll let MovementController handle the jump.
	pass

func physics_update(delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	player.movement_controller.move(input_dir, delta)
	
	if player.is_on_floor():
		if input_dir:
			state_machine.change_state_by_path("Moving")
		else:
			state_machine.change_state_by_path("Idle")
