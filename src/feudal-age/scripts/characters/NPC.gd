class_name NPC
extends CharacterBody3D

signal waypoint_reached(waypoint_index: int)

@export var patrol_points: Array[Vector3] = []
@export var npc_name: String = "Peasant"

## Coordinator-assigned tracking ID. Set at runtime by NPCCoordinator.
var id: int = -1

var management_comp: ManagementPopulantComponent = null

@onready var state_m: StateMachine = $StateMachine
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var visuals: PeasantCharacter = $PeasantCharacter
@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var status_label: Label3D = $StatusLabel

func _ready() -> void:
	# Retrieve or create component dynamically to ensure backward compatibility
	management_comp = get_node_or_null("ManagementPopulantComponent") as ManagementPopulantComponent
	if not management_comp:
		management_comp = ManagementPopulantComponent.new()
		management_comp.name = "ManagementPopulantComponent"
		# ID must be set BEFORE add_child(): the component's _ready() fires
		# synchronously here and registers with ManagementAPI under this key.
		management_comp.character_id = id if id != -1 else name.hash()
		add_child(management_comp)

	# Align IDs for scene-defined components (preserve Coordinator-assigned ID).
	# The component re-keys its own registration if the ID changes after _ready().
	if management_comp.character_id <= 0:
		var old_id: int = management_comp.character_id
		management_comp.character_id = id if id != -1 else name.hash()
		management_comp.notify_character_id_changed(old_id)

	if interactable_component:
		interactable_component.interacted.connect(_on_interacted)

	if state_m:
		state_m.state_changed.connect(_on_state_changed)
		_on_state_changed(state_m.initial_state.name if state_m.initial_state else "None")

	print("NPC initialized: ", npc_name)

func _physics_process(_delta: float) -> void:
	move_and_slide()

func _on_state_changed(state_name: String) -> void:
	if status_label:
		status_label.text = npc_name + " (" + state_name + ")"

func _on_interacted(_interactor: Node3D) -> void:
	if state_m:
		state_m.change_state_by_path("Interact")

## Called by external systems (ManagementAPI, player UI) to put the NPC into assigned work mode.
func assign_to_work() -> void:
	if state_m:
		state_m.change_state_by_path("AssignedWork")
