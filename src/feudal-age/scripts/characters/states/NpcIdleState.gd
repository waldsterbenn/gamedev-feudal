# ============================================================================
# LEGACY CODE — outside the Management module and Terrain generator.
# Retained for now; scheduled for refactor or removal. Do not extend.
# ============================================================================
extends StateNode

## Idle: stand still. Animation is driven by the state_changed mapping in
## NPC._on_state_changed (Idle -> Idle_A) via the CharacterAnimationComponent.

func enter(_data: Dictionary = {}) -> void:
	var npc: NPC = owner as NPC
	if npc:
		npc.velocity = Vector3.ZERO

func physics_update(_delta: float) -> void:
	var npc: NPC = owner as NPC
	if npc:
		npc.velocity = Vector3.ZERO
