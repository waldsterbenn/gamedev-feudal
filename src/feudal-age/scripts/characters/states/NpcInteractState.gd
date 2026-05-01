extends StateNode

@export var interact_duration: float = 2.0

var _timer: float = 0.0

func enter(_data: Dictionary = {}) -> void:
	_timer = interact_duration
	var npc: NpcPeasant = owner as NpcPeasant
	if npc and npc.visuals:
		npc.visuals.play_animation("Take 001")
	if npc:
		npc.velocity = Vector3.ZERO
		EventBus.npc_interacted.emit(npc.name)

func update(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		state_machine.change_state_by_path("Idle")

func physics_update(_delta: float) -> void:
	var npc: NpcPeasant = owner as NpcPeasant
	if npc:
		npc.velocity = Vector3.ZERO
