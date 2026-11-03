# ============================================================================
# LEGACY CODE — outside the Management module and Terrain generator.
# Retained for now; scheduled for refactor or removal. Do not extend.
# ============================================================================
extends CharacterBody3D

signal health_changed(current_health: float, max_health: float)

@onready var state_machine: StateMachine = $StateMachine
@onready var movement_controller: ThirdPersonControler3D = $ThirdPersonControler3D
@onready var health_component: HealthComponent = $HealthComponent
@onready var visuals: CharacterAnimationComponent = $PeasantCharacter

func _ready() -> void:
	if health_component:
		health_component.health_changed.connect(_on_health_changed)
	# State-driven animation: the player state machine drives clips via the
	# component (Idle/Moving/Jumping), same mechanism as NPC states (#78).
	if state_machine:
		state_machine.state_changed.connect(_on_state_changed)
		if state_machine.current_state:
			_on_state_changed(state_machine.current_state.name)
	# Emit player initialization log via EventBus
	EventBus.ui.message_logged.emit("Player initialized", "info")

func _physics_process(_delta: float) -> void:
	move_and_slide()

func _on_state_changed(state_name: StringName) -> void:
	if not visuals:
		return
	match state_name:
		"Moving":
			var speed: float = movement_controller.GetSpeed(0.0) if movement_controller else 10.0
			if speed > 12.0:
				visuals.play_clip("Running_A", speed)
			else:
				visuals.play_clip("Walking_A", speed)
		_:
			visuals.play_for_state(String(state_name))

func _on_health_changed(current_health: float, max_health: float) -> void:
	health_changed.emit(current_health, max_health)
