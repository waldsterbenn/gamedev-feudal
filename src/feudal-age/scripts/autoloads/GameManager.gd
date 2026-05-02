extends Node

enum GameState { MAIN_MENU, PLAYING, PAUSED, GAME_OVER, DOMAIN_SCREEN }

var current_state: GameState = GameState.MAIN_MENU
var current_domain: String = ""
var gold: int = 0
var prestige: int = 0
var current_season: int = 0  # 0=Spring, 1=Summer, 2=Autumn, 3=Winter

var _active_petition_choices: Array = []

func _ready() -> void:
	EventBus.gold_change_requested.connect(update_gold)
	EventBus.prestige_change_requested.connect(update_prestige)
	EventBus.petition_started.connect(_on_petition_started)
	EventBus.petition_resolved.connect(_on_petition_resolved)

func _on_petition_started(_petitioner: Node3D, _title: String, _desc: String, choices: Array[Dictionary]) -> void:
	_active_petition_choices = choices
	set_pause_state(true)

func _on_petition_resolved(petitioner: Node3D, choice_index: int) -> void:
	if choice_index >= 0 and choice_index < _active_petition_choices.size():
		var choice = _active_petition_choices[choice_index]
		
		if choice.has("gold_delta"):
			update_gold(choice.get("gold_delta", 0))
		
		if choice.has("prestige_delta"):
			update_prestige(choice.get("prestige_delta", 0))
			
		if choice.has("opinion_delta") and petitioner is NpcPeasant:
			petitioner.change_opinion(choice.get("opinion_delta", 0))
			
		EventBus.message_logged.emit("Petition resolved by " + petitioner.npc_name, "info")
	
	_active_petition_choices = []
	set_pause_state(false)

func change_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)

func update_gold(delta: int) -> void:
	gold += delta
	EventBus.gold_changed.emit(gold)

func update_prestige(delta: int) -> void:
	prestige += delta
	EventBus.prestige_changed.emit(prestige)

func set_pause_state(paused: bool) -> void:
	get_tree().paused = paused
	current_state = GameState.PAUSED if paused else GameState.PLAYING
	if paused:
		EventBus.game_paused.emit()
	else:
		EventBus.game_resumed.emit()
