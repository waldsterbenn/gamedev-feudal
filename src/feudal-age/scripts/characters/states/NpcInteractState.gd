# ============================================================================
# LEGACY CODE — outside the Management module and Terrain generator.
# Retained for now; scheduled for refactor or removal. Do not extend.
# ============================================================================
extends StateNode

@export var interact_duration: float = 2.0

var _timer: float = 0.0

func enter(_data: Dictionary = {}) -> void:
	_timer = interact_duration
	var npc: NpcPeasant = owner as NpcPeasant
	if npc:
		npc.velocity = Vector3.ZERO
		if npc.visuals:
			npc.visuals.play_animation("Take 001")
		# TODO(event-system): raise a petition via replacement for legacy EventBus.petition_started/npc_interacted

func update(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		state_machine.change_state_by_path("Idle")

func physics_update(_delta: float) -> void:
	var npc: NpcPeasant = owner as NpcPeasant
	if npc:
		npc.velocity = Vector3.ZERO
