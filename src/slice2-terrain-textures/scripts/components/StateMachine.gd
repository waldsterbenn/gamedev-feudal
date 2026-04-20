class_name StateMachine
extends Node
# StateMachine.gd - Manages State nodes and transitions

# 1. signals
signal state_changed(new_state_name: String)

# 2. exports
@export var initial_state: State

# 3. public vars
var current_state: State

# 4. built-in callbacks
func _ready() -> void:
	await owner.ready
	if not initial_state:
		# If no initial state is set, try to find the first child that is a State
		for child in get_children():
			if child is State:
				initial_state = child
				break
	
	if initial_state:
		change_state(initial_state)

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

# 5. public functions
func change_state(new_state: State, data: Dictionary = {}) -> void:
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter(data)
	state_changed.emit(current_state.name)

func change_state_by_path(path: String, data: Dictionary = {}) -> void:
	var new_state: State = get_node(path) as State
	if new_state:
		change_state(new_state, data)
