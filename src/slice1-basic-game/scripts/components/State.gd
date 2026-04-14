class_name State
extends Node
# State.gd - Base class for all states in a StateMachine

# 1. signals
signal finished(next_state_path: String, data: Dictionary)

# 2. public vars
var state_machine: StateMachine

# 3. built-in callbacks
func _ready() -> void:
	await owner.ready
	state_machine = get_parent() as StateMachine
	if not state_machine:
		push_error("State node must be a child of a StateMachine")

# 3. virtual methods
func enter(data: Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	pass
