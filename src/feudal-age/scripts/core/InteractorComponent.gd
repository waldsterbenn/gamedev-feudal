# ============================================================================
# LEGACY CODE — outside the Management module and Terrain generator.
# Retained for now; scheduled for refactor or removal. Do not extend.
# ============================================================================
class_name InteractorComponent
extends RayCast3D

signal can_interact(interactable: InteractableComponent)
signal cannot_interact

@export var interaction_action: String = "interact"

var _current_interactable: InteractableComponent = null

func _physics_process(_delta: float) -> void:
	_check_interaction()
	if Input.is_action_just_pressed(interaction_action):
		_interact()

func _check_interaction() -> void:
	var collider: Node = get_collider()
	var interactable: InteractableComponent = null
	
	if collider:
		if collider is InteractableComponent:
			interactable = collider
		else:
			# Look in children first
			interactable = collider.find_child("InteractableComponent", true, false) as InteractableComponent
			# If still not found, look in parent (e.g. if the RayCast hit a mesh child)
			if not interactable:
				var parent: Node = collider.get_parent()
				if parent:
					interactable = parent.find_child("InteractableComponent", true, false) as InteractableComponent
			
	if interactable:
		if _current_interactable != interactable:
			_update_interactable(interactable)
	else:
		if _current_interactable != null:
			_update_interactable(null)

func _update_interactable(interactable: InteractableComponent) -> void:
	if _current_interactable:
		_current_interactable.unfocus(owner)
	_current_interactable = interactable
	if _current_interactable:
		_current_interactable.focus(owner)
		can_interact.emit(_current_interactable)
		# TODO(event-system): surface this via the replacement for legacy EventBus.message_logged
		print("Near: ", _current_interactable.interaction_name)
	else:
		cannot_interact.emit()

func _interact() -> void:
	if _current_interactable:
		_current_interactable.interact(owner)
