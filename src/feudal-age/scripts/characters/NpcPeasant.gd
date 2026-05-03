class_name NpcPeasant
extends CharacterBody3D

signal waypoint_reached(waypoint_index: int)

@export var patrol_points: Array[Vector3] = []
@export var npc_name: String = "Peasant"
@export var profile: VassalProfile = null

var current_fief: Fief = null

@onready var state_m: StateMachine = $StateMachine
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var visuals: PeasantCharacter = $PeasantCharacter
@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var health_comp: HealthComponent = $HealthComponent
@onready var status_label: Label3D = $StatusLabel

func _ready() -> void:
	if not profile:
		profile = VassalProfile.new()
		profile.vassal_name = npc_name
	
	if interactable_component:
		interactable_component.interacted.connect(_on_interacted)
	
	if state_m:
		state_m.state_changed.connect(_on_state_changed)
		_on_state_changed(state_m.initial_state.name if state_m.initial_state else "None")
	
	EventBus.message_logged.emit("NPC initialized: " + npc_name, "info")

func _physics_process(_delta: float) -> void:
	# Base gravity is handled in states by setting velocity.y
	# We just perform the move here
	move_and_slide()

func _on_state_changed(state_name: String) -> void:
	if status_label:
		var loyalty_text: String = ""
		if profile:
			loyalty_text = "\nLoyalty: " + str(profile.loyalty)
		status_label.text = npc_name + " (" + state_name + ")" + loyalty_text

func change_opinion(delta: int) -> void:
	if profile:
		profile.change_opinion(delta)
		EventBus.vassal_loyalty_changed.emit(npc_name, profile.loyalty)
		_on_state_changed(state_m.current_state.name if state_m.current_state else "None")

func change_fear(delta: int) -> void:
	if profile:
		profile.change_fear(delta)
		EventBus.vassal_loyalty_changed.emit(npc_name, profile.loyalty)
		_on_state_changed(state_m.current_state.name if state_m.current_state else "None")

func _on_interacted(_interactor: Node3D) -> void:
	state_m.change_state_by_path("Interact")
