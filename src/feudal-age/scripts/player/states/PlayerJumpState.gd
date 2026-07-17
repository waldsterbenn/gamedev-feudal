# ============================================================================
# LEGACY CODE — outside the Management module and Terrain generator.
# Retained for now; scheduled for refactor or removal. Do not extend.
# ============================================================================
extends PlayerStateBase

func enter(_data: Dictionary = {}) -> void:
	pass

func physics_update(_delta: float) -> void:
	if player and player.is_on_floor():
		var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		if input_dir:
			state_machine.change_state_by_path("Moving")
		else:
			state_machine.change_state_by_path("Idle")
