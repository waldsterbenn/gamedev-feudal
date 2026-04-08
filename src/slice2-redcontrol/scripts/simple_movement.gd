extends MeshInstance3D

var target_position = Vector3(1, 0, 0)
var start_position = Vector3(-1, 0, 0)
var move_speed = 1.0
var moving_to_target = true

func _ready():
	# Start at the start position
	transform.origin = start_position

func _process(delta):
	# Move towards the target
	var direction = (target_position - transform.origin).normalized()
	transform.origin += direction * move_speed * delta
	
	# Check if we've reached the target
	if (transform.origin - target_position).length() < 0.1:
		# Switch target
		if moving_to_target:
			target_position = start_position
			moving_to_target = false
		else:
			target_position = Vector3(1, 0, 0)
			moving_to_target = true