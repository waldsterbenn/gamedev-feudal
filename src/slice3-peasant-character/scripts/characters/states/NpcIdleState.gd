class_name NpcIdleState
extends State
# NpcIdleState.gd - Idle behavior for NPC peasant

# 1. exports
@export var idle_duration_min: float = 1.0
@export var idle_duration_max: float = 3.0

# 2. private vars
var _timer: float = 0.0

# 3. virtual methods
func enter(_data: Dictionary = {}) -> void:
	_timer = randf_range(idle_duration_min, idle_duration_max)
	var npc: NpcPeasant = owner as NpcPeasant
	if npc and npc.visuals:
		npc.visuals.play_animation("Take 001")

func update(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		state_machine.change_state_by_path("Patrol")

func physics_update(_delta: float) -> void:
	var npc: NpcPeasant = owner as NpcPeasant
	if npc:
		npc.velocity = Vector3.ZERO
