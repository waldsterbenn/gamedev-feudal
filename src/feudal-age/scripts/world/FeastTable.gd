class_name FeastTable
extends StaticBody3D

@export var feast_cost: int = 50
@export var opinion_boost: int = 20
@export var effect_radius: float = 10.0

@onready var interactable: InteractableComponent = $InteractableComponent

func _ready() -> void:
	if interactable:
		interactable.interacted.connect(_on_interacted)
		interactable.interaction_name = "Hold Feast"
		interactable.interaction_description = "Costs " + str(feast_cost) + " gold"

func _on_interacted(_interactor: Node3D) -> void:
	if GameManager.gold >= feast_cost:
		GameManager.update_gold(-feast_cost)
		_hold_feast()
	else:
		EventBus.message_logged.emit("Not enough gold for a feast!", "warn")

func _hold_feast() -> void:
	EventBus.message_logged.emit("You held a grand feast!", "info")
	
	# Find all vassals in radius
	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	var shape: SphereShape3D = SphereShape3D.new()
	shape.radius = effect_radius
	query.shape = shape
	query.transform = global_transform
	query.collision_mask = 2 # Player/Enemies/NPCs layer if set correctly
	
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var results: Array[Dictionary] = space_state.intersect_shape(query)
	
	for result in results:
		var collider: Node = result.collider
		if collider is NpcPeasant:
			collider.change_opinion(opinion_boost)
			EventBus.message_logged.emit(collider.npc_name + " enjoyed the feast", "info")
