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
		
		# Sample Petition
		var choices: Array[Dictionary] = [
			{
				"text": "Forgive taxes",
				"gold_delta": -20,
				"opinion_delta": 20,
				"prestige_delta": 5
			},
			{
				"text": "Demand payment",
				"gold_delta": 0,
				"opinion_delta": -20,
				"prestige_delta": -5
			}
		]
		EventBus.petition_started.emit(
			npc, 
			"Tax Relief Request", 
			"The harvest was poor. May we have relief?", 
			choices
		)
		EventBus.npc_interacted.emit(npc.npc_name)

func update(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		state_machine.change_state_by_path("Idle")

func physics_update(_delta: float) -> void:
	var npc: NpcPeasant = owner as NpcPeasant
	if npc:
		npc.velocity = Vector3.ZERO
