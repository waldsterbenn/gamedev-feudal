class_name Player
extends CharacterBody3D
# Player.gd - Main player controller

# 1. signals
signal health_changed(current_health: float, max_health: float)

# 2. onready
@onready var state_machine: StateMachine = $StateMachine
@onready var movement_controller: MovementController = $MovementController
@onready var health_component: HealthComponent = $HealthComponent

# 3. built-in callbacks
func _ready() -> void:
	health_component.health_changed.connect(_on_health_changed)
	EventBus.message_logged.emit("Player initialized", "info")

# 4. private functions
func _on_health_changed(current_health: float, max_health: float) -> void:
	health_changed.emit(current_health, max_health)
