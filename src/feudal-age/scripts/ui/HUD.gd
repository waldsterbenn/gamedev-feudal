extends Control

@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/HealthBar
@onready var gold_label: Label = $MarginContainer/VBoxContainer/GoldLabel
@onready var prestige_label: Label = $MarginContainer/VBoxContainer/PrestigeLabel
@onready var season_label: Label = $MarginContainer/VBoxContainer/SeasonLabel
@onready var message_label: Label = $MarginContainer/VBoxContainer/MessageLabel
@onready var loyalty_label: Label = $MarginContainer/VBoxContainer/LoyaltyLabel

func _ready() -> void:
	EventBus.gold_changed.connect(_on_gold_changed)
	EventBus.prestige_changed.connect(_on_prestige_changed)
	EventBus.season_changed.connect(_on_season_changed)
	EventBus.message_logged.connect(_on_message_logged)
	EventBus.vassal_loyalty_changed.connect(_on_loyalty_changed)
	
	_on_season_changed(GameManager.current_season)
	
	var player: Node = get_tree().get_first_node_in_group("player")
	if player:
		_connect_player(player)
	else:
		get_tree().node_added.connect(_on_node_added)

func _on_gold_changed(new_amount: int) -> void:
	gold_label.text = "Gold: " + str(new_amount)

func _on_prestige_changed(new_amount: int) -> void:
	prestige_label.text = "Prestige: " + str(new_amount)

func _on_season_changed(season_index: int) -> void:
	season_label.text = "Season: " + GameManager.season_names[season_index]

func _on_loyalty_changed(vassal_name: String, amount: int) -> void:
	loyalty_label.text = vassal_name + " Loyalty: " + str(amount)
	await get_tree().create_timer(5.0).timeout
	if loyalty_label.text == (vassal_name + " Loyalty: " + str(amount)):
		loyalty_label.text = ""

func _on_message_logged(message: String, _level: String) -> void:
	message_label.text = message
	await get_tree().create_timer(3.0).timeout
	if message_label.text == message:
		message_label.text = ""

func _on_node_added(node: Node) -> void:
	if node.is_in_group("player"):
		_connect_player(node)
		get_tree().node_added.disconnect(_on_node_added)

func _connect_player(player: Node) -> void:
	var health_comp: HealthComponent = player.get_node_or_null("HealthComponent") as HealthComponent
	if health_comp:
		health_comp.health_changed.connect(_on_health_changed)
		_on_health_changed(health_comp.get_health(), health_comp.max_health)

func _on_health_changed(current: float, max_val: float) -> void:
	health_bar.max_value = max_val
	health_bar.value = current
