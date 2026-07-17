# ============================================================================
# LEGACY CODE — outside the Management module and Terrain generator.
# Retained for now; scheduled for refactor or removal. Do not extend.
# ============================================================================
extends CharacterBody3D

signal health_changed(current_health: float, max_health: float)

@onready var state_machine: StateMachine = $StateMachine
@onready var movement_controller: ThirdPersonControler3D = $ThirdPersonControler3D
@onready var health_component: HealthComponent = $HealthComponent

func _ready() -> void:
	if health_component:
		health_component.health_changed.connect(_on_health_changed)
	# TODO(event-system): announce player init via the replacement for legacy EventBus.message_logged
	print("Player initialized")

func _physics_process(_delta: float) -> void:
	move_and_slide()

func _on_health_changed(current_health: float, max_health: float) -> void:
	health_changed.emit(current_health, max_health)
