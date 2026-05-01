class_name InteractableComponent
extends Area3D

signal interacted(interactor: Node3D)
signal focused(interactor: Node3D)
signal unfocused(interactor: Node3D)

@export var interaction_name: String = "Interact"
@export var interaction_description: String = ""

func interact(interactor: Node3D) -> void:
	interacted.emit(interactor)
	EventBus.message_logged.emit("Interacted with: " + interaction_name, "info")

func focus(interactor: Node3D) -> void:
	focused.emit(interactor)

func unfocus(interactor: Node3D) -> void:
	unfocused.emit(interactor)
