# ============================================================================
# LEGACY CODE — outside the Management module and Terrain generator.
# Retained for now; scheduled for refactor or removal. Do not extend.
# ============================================================================
extends PlayerStateBase

func enter(_data: Dictionary = {}) -> void:
	pass

func physics_update(_delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if input_dir:
		state_machine.change_state_by_path("Moving")
	elif player and Input.is_action_just_pressed("jump") and player.is_on_floor():
		state_machine.change_state_by_path("Jumping")
