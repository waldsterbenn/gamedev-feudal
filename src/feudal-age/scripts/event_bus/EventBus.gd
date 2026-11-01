extends Node

@onready var ui: EventBusUI = $UI
@onready var audio: EventBusAudio = $Audio
@onready var vfx: EventBusVFX = $VFX

## Emitted after every registered module has processed a day tick (day >= 1)
signal day_ticked(day: int)

func _ready() -> void:
	print("EventBus: Core bus initialized successfully.")
