class_name StateNode
extends Node

var state_machine: StateMachine
var owner_node: Node

func _ready() -> void:
	state_machine = get_parent() as StateMachine
	if not state_machine:
		push_error("StateNode must be a child of a StateMachine")
	owner_node = owner if owner else null

func enter(_data: Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
