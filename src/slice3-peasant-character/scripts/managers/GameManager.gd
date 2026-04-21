extends Node
# GameManager.gd - Global singleton for game state management

# 1. signals
signal game_started
signal game_paused(is_paused: bool)

# 2. public vars
var is_paused: bool = false

# 3. built-in callbacks
func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS

# 4. public functions
func toggle_pause() -> void:
	is_paused = !is_paused
	get_tree().paused = is_paused
	game_paused.emit(is_paused)
