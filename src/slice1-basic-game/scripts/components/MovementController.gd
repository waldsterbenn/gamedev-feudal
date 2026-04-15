class_name MovementController
extends Node
# MovementController.gd - Manages movement for a CharacterBody3D

# 1. signals
signal moved(velocity: Vector3)

# 2. exports
@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var acceleration: float = 10.0
@export var friction: float = 10.0
@export var mouse_sensitivity: float = 0.003
@export var spring_arm: SpringArm3D

# 3. private vars
var _body: CharacterBody3D
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# 4. built-in callbacks
func _ready() -> void:
	_body = owner as CharacterBody3D
	if not _body:
		push_error("MovementController must be a child of a CharacterBody3D")
	
	# Initial capture attempt
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if not _body:
		return
	
	# Capture mouse on click if it's not already captured
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Rotate body horizontally (Yaw)
		_body.rotate_y(-event.relative.x * mouse_sensitivity)
		
		# Rotate spring arm vertically (Pitch)
		if spring_arm:
			spring_arm.rotate_x(-event.relative.y * mouse_sensitivity)
			# Clamp pitch to avoid flipping or looking too far up/down
			# -90 to 30 degrees is usually a good range for 3rd person
			spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(-80), deg_to_rad(60))

	# Toggle mouse capture for testing/debugging
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# 5. public functions
func move(input_dir: Vector2, delta: float) -> void:
	if not _body:
		return
	
	# Add gravity
	if not _body.is_on_floor():
		_body.velocity.y -= _gravity * delta
	
	# Handle Jump
	if Input.is_action_just_pressed("jump") and _body.is_on_floor():
		_body.velocity.y = jump_velocity
	
	# Calculate direction
	var direction: Vector3 = (_body.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		_body.velocity.x = lerp(_body.velocity.x, direction.x * speed, acceleration * delta)
		_body.velocity.z = lerp(_body.velocity.z, direction.z * speed, acceleration * delta)
	else:
		_body.velocity.x = lerp(_body.velocity.x, 0.0, friction * delta)
		_body.velocity.z = lerp(_body.velocity.z, 0.0, friction * delta)
	
	_body.move_and_slide()
	moved.emit(_body.velocity)
