extends Control

@onready var title_label: Label = $Panel/VBoxContainer/Title
@onready var desc_label: Label = $Panel/VBoxContainer/Description
@onready var choices_container: HBoxContainer = $Panel/VBoxContainer/Choices

var _petitioner: Node3D = null

func _ready() -> void:
	hide()
	EventBus.petition_started.connect(_on_petition_started)

func _on_petition_started(petitioner: Node3D, title: String, description: String, choices: Array[Dictionary]) -> void:
	_petitioner = petitioner
	title_label.text = title
	desc_label.text = description
	
	# Clear old choices
	for child in choices_container.get_children():
		child.queue_free()
	
	# Add new choices
	for i in range(choices.size()):
		var choice = choices[i]
		var btn = Button.new()
		btn.text = choice["text"]
		btn.pressed.connect(_on_choice_selected.bind(i))
		choices_container.add_child(btn)
	
	show()

func _on_choice_selected(index: int) -> void:
	EventBus.petition_resolved.emit(_petitioner, index)
	hide()
