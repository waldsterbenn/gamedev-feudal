class_name NpcPeasant
extends CharacterBody3D
# NpcPeasant.gd - Main controller for the NPC peasant character

# 1. exports
@export var patrol_points: Array[Vector3] = []
@export var npc_name: String = "Peasant"

# 2. signals
signal waypoint_reached(waypoint_index: int)

# 3. onready
@onready var state_machine: StateMachine = $StateMachine
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var visuals: PeasantCharacter = $PeasantCharacter
@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var health_component: HealthComponent = $HealthComponent

# 4. built-in callbacks
func _ready() -> void:
	if interactable_component:
		interactable_component.interacted.connect(_on_interacted)
	EventBus.message_logged.emit("NPC initialized: " + name, "info")

func _physics_process(_delta: float) -> void:
	move_and_slide()

# 5. private functions
func _on_interacted(_interactor: Node3D) -> void:
	state_machine.change_state_by_path("Interact")
