extends StaticBody3D

func _ready() -> void:
	var interactable: InteractableComponent = $InteractableComponent
	if interactable:
		interactable.interacted.connect(_on_interacted)

func _on_interacted(_interactor: Node3D) -> void:
	EventBus.gold_change_requested.emit(10)
	EventBus.message_logged.emit("You found 10 gold!", "info")
	interactable.set_deferred("monitoring", false)
	interactable.set_deferred("monitorable", false)
	queue_free()
