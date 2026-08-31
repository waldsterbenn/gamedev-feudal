extends Node

@onready var ui: EventBusUI = $UI
@onready var audio: EventBusAudio = $Audio
@onready var vfx: EventBusVFX = $VFX

func _ready() -> void:
	print("EventBus: Core bus initialized successfully.")
