extends Control
# HUD.gd - Manages the game's heads-up display

# 1. onready
@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/HealthBar
@onready var gold_label: Label = $MarginContainer/VBoxContainer/GoldLabel
@onready var message_label: Label = $MarginContainer/VBoxContainer/MessageLabel

# 2. built-in callbacks
func _ready() -> void:
	EventBus.gold_changed.connect(_on_gold_changed)
	EventBus.message_logged.connect(_on_message_logged)
	
	# Try to find player in the scene tree to connect to health
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if player:
		_connect_player(player)
	else:
		# If player not yet in tree, wait for it
		get_tree().node_added.connect(_on_node_added)

# 3. private functions
func _on_gold_changed(new_amount: int) -> void:
	gold_label.text = "Gold: " + str(new_amount)

func _on_message_logged(message: String, _level: String) -> void:
	message_label.text = message
	# Simple fade out could be added here
	await get_tree().create_timer(3.0).timeout
	if message_label.text == message:
		message_label.text = ""

func _on_node_added(node: Node) -> void:
	if node.is_in_group("player"):
		_connect_player(node as Player)
		get_tree().node_added.disconnect(_on_node_added)

func _connect_player(player: Player) -> void:
	var health_comp: HealthComponent = player.get_node_or_null("HealthComponent") as HealthComponent
	if health_comp:
		health_comp.health_changed.connect(_on_health_changed)
		_on_health_changed(health_comp.get_health(), health_comp.max_health)

func _on_health_changed(current: float, max_val: float) -> void:
	health_bar.max_value = max_val
	health_bar.value = current
