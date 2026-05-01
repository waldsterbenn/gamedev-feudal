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

func _ready() -> void:
	if not profile:
		profile = VassalProfile.new()
		profile.vassal_name = npc_name
	
	if interactable_component:
		interactable_component.interacted.connect(_on_interacted)
	EventBus.message_logged.emit("NPC initialized: " + name, "info")

func _physics_process(_delta: float) -> void:
	move_and_slide()

func change_opinion(delta: int) -> void:
	if profile:
		profile.change_opinion(delta)
		EventBus.vassal_loyalty_changed.emit(npc_name, profile.loyalty)

func change_fear(delta: int) -> void:
	if profile:
		profile.change_fear(delta)
		EventBus.vassal_loyalty_changed.emit(npc_name, profile.loyalty)

func _on_interacted(_interactor: Node3D) -> void:
	state_m.change_state_by_path("Interact")
