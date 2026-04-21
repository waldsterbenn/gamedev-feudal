extends StaticBody3D
# GoldChest.gd - A simple interactable chest that gives gold

# 1. onready
@onready var interactable: InteractableComponent = $InteractableComponent

# 2. built-in callbacks
func _ready() -> void:
	interactable.interacted.connect(_on_interacted)

# 3. private functions
func _on_interacted(_interactor: Node3D) -> void:
	EventBus.gold_changed.emit(10)
	EventBus.message_logged.emit("You found 10 gold!", "info")
	# In a real game, we might play an animation and then disable the chest
	interactable.set_deferred("monitoring", false)
	interactable.set_deferred("monitorable", false)
	# For now, let's just make it disappear or change color (if we had a material)
	queue_free()
