extends CanvasLayer
@onready var label: Label = %InstructionsLabel
func _ready() -> void:
	label.text = "Tab = Management Mode | Arrow Keys = Select Zone | Enter = Inspect | B = Build"
