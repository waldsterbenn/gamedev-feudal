extends Node

enum GameState { MAIN_MENU, PLAYING, PAUSED, GAME_OVER, DOMAIN_SCREEN }

var current_state: GameState = GameState.MAIN_MENU
var current_domain: String = ""
var gold: int = 0
var prestige: int = 0
var current_season: int = 0  # 0=Spring, 1=Summer, 2=Autumn, 3=Winter

func _ready() -> void:
	EventBus.gold_change_requested.connect(update_gold)

func change_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)

func update_gold(delta: int) -> void:
	gold += delta
	EventBus.gold_changed.emit(gold)

func set_pause_state(paused: bool) -> void:
	get_tree().paused = paused
	current_state = GameState.PAUSED if paused else GameState.PLAYING
	if paused:
		EventBus.game_paused.emit()
	else:
		EventBus.game_resumed.emit()
