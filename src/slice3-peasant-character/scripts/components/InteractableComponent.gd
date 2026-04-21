class_name InteractableComponent
extends Area3D
# InteractableComponent.gd - Component to make an object interactable

# 1. signals
signal interacted(interactor: Node3D)
signal focused(interactor: Node3D)
signal unfocused(interactor: Node3D)

# 2. exports
@export var interaction_name: String = "Interact"
@export var interaction_description: String = ""

# 3. public functions
func interact(interactor: Node3D) -> void:
	interacted.emit(interactor)
	EventBus.message_logged.emit("Interacted with: " + interaction_name, "info")

func focus(interactor: Node3D) -> void:
	focused.emit(interactor)

func unfocus(interactor: Node3D) -> void:
	unfocused.emit(interactor)
