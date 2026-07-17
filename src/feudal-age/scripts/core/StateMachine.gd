# ============================================================================
# LEGACY CODE — outside the Management module and Terrain generator.
# Retained for now; scheduled for refactor or removal. Do not extend.
# ============================================================================
class_name StateMachine
extends Node

signal state_changed(new_state_name: StringName)

@export var initial_state: StateNode
var current_state: StateNode
var states: Dictionary = {}

func _ready() -> void:
	await owner.ready
	for child: Node in get_children():
		if child is StateNode:
			states[child.name.to_lower()] = child
			child.state_machine = self
			child.process_mode = Node.PROCESS_MODE_DISABLED
	if not initial_state:
		for s: StateNode in states.values():
			initial_state = s
			break
	if initial_state:
		_transition_to(initial_state.name.to_lower())

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _transition_to(state_name: StringName, data: Dictionary = {}) -> void:
	if current_state:
		current_state.exit()
		current_state.process_mode = Node.PROCESS_MODE_DISABLED
	var _previous: StateNode = current_state
	current_state = states.get(state_name)
	if current_state:
		current_state.process_mode = Node.PROCESS_MODE_INHERIT
		current_state.enter(data)
		state_changed.emit(current_state.name)

func change_state(new_state: StateNode, data: Dictionary = {}) -> void:
	for s: StateNode in states.values():
		if s == new_state:
			_transition_to(s.name.to_lower(), data)
			return

func change_state_by_path(path: String, data: Dictionary = {}) -> void:
	var new_state: StateNode = get_node_or_null(path) as StateNode
	if new_state:
		_transition_to(new_state.name.to_lower(), data)
