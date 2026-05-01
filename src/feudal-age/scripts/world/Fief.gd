class_name Fief
extends Area3D

signal prosperity_changed(new_prosperity: float)
signal gold_yield_ready(amount: int)

@export var fief_name: String = "My Manor"
@export var base_yield: float = 1.0  # Gold per peasant per cycle
@export var tax_rate: float = 0.2    # Lord's share

var prosperity: float = 100.0
var tenants: Array[NpcPeasant] = []
var accumulated_gold: float = 0.0

@onready var yield_timer: Timer = $YieldTimer

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	var interactable: InteractableComponent = get_node_or_null("InteractableComponent")
	if interactable:
		interactable.interacted.connect(_on_interacted)
		interactable.interaction_name = "Collect Taxes"
	
	if not yield_timer:
		yield_timer = Timer.new()
		add_child(yield_timer)
		yield_timer.wait_time = 10.0  # Cycle every 10 seconds
		yield_timer.autostart = true
		yield_timer.timeout.connect(_process_yield)

func _on_interacted(_interactor: Node3D) -> void:
	collect_taxes()

func _on_body_entered(body: Node3D) -> void:
	if body is NpcPeasant:
		if not tenants.has(body):
			tenants.append(body)
			body.current_fief = self
			EventBus.message_logged.emit(body.npc_name + " entered " + fief_name, "info")

func _on_body_exited(body: Node3D) -> void:
	if body is NpcPeasant:
		if tenants.has(body):
			tenants.erase(body)
			if body.current_fief == self:
				body.current_fief = null
			EventBus.message_logged.emit(body.npc_name + " left " + fief_name, "info")

func _process_yield() -> void:
	if tenants.is_empty():
		return
		
	var cycle_gold: float = tenants.size() * base_yield * (prosperity / 100.0)
	var lords_share: int = int(cycle_gold * tax_rate)
	
	if lords_share > 0:
		accumulated_gold += lords_share
		gold_yield_ready.emit(int(accumulated_gold))
		EventBus.message_logged.emit(fief_name + " generated " + str(lords_share) + " gold tax", "info")

func collect_taxes() -> void:
	var total: int = int(accumulated_gold)
	if total > 0:
		EventBus.gold_change_requested.emit(total)
		accumulated_gold -= total
		EventBus.message_logged.emit("Collected " + str(total) + " gold from " + fief_name, "info")
	else:
		EventBus.message_logged.emit("No taxes to collect in " + fief_name, "info")
