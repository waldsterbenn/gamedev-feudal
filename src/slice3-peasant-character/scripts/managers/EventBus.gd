extends Node
# EventBus.gd - Global singleton for decoupled communication

# 1. signals
signal gold_changed(new_amount: int)
signal message_logged(message: String, level: String)

signal interaction_started(interactable: Node)
signal interaction_finished(interactable: Node)

signal npc_interacted(npc_name: String)

# 2. built-in callbacks
func _ready() -> void:
	message_logged.emit("EventBus initialized", "info")
