class_name InteractorComponent
extends RayCast3D
# InteractorComponent.gd - Component to interact with InteractableComponents

# 1. signals
signal can_interact(interactable: InteractableComponent)
signal cannot_interact

# 2. exports
@export var interaction_action: String = "interact"

# 3. private vars
var _current_interactable: InteractableComponent = null

# 4. built-in callbacks
func _physics_process(_delta: float) -> void:
	_check_interaction()
	
	if Input.is_action_just_pressed(interaction_action):
		_interact()

# 5. private functions
func _check_interaction() -> void:
	var collider: Node3D = get_collider() as Node3D
	
	if collider is InteractableComponent:
		if _current_interactable != collider:
			_update_interactable(collider)
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
	else:
		cannot_interact.emit()

func _interact() -> void:
	if _current_interactable:
		_current_interactable.interact(owner)
