# ============================================================================
# LEGACY CODE — outside the Management module and Terrain generator.
# Retained for now; scheduled for refactor or removal. Do not extend.
# ============================================================================
class_name PlayerStateBase
extends StateNode

var player: CharacterBody3D

func _ready() -> void:
	super._ready()
	var current: Node = self
	while current:
		if current is CharacterBody3D and current.is_in_group("player"):
			player = current as CharacterBody3D
			break
		current = current.get_parent()
	if not player:
		push_warning("PlayerState: owner node in group 'player' not found")
