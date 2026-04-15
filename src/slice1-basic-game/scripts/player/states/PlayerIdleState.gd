class_name PlayerIdleState
extends PlayerState
# PlayerIdleState.gd - Idle behavior

# 1. virtual methods
func enter(data: Dictionary = {}) -> void:
	pass

func physics_update(_delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if input_dir:
		state_machine.change_state_by_path("Moving")
	elif Input.is_action_just_pressed("jump") and player.is_on_floor():
		state_machine.change_state_by_path("Jumping")
