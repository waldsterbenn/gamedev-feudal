extends MeshInstance3D

var move_speed = 5.0
var move_direction = Vector3.ZERO

func _ready():
	# Make sure the red ball starts at the right position
	transform.origin = Vector3(1, 0, 0)

func _process(delta):
	# Handle keyboard input
	move_direction = Vector3.ZERO
	
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		move_direction.z -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		move_direction.z += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		move_direction.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		move_direction.x += 1
	
	# Normalize diagonal movement
	if move_direction.length() > 0:
		move_direction = move_direction.normalized()
	
	# Move the ball
	transform.origin += move_direction * move_speed * delta