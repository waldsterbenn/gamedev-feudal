extends Camera3D

# Camera follow parameters
var follow_distance = 8.0  # Distance IN FRONT of the ball (third-person view)
var follow_height = 4.0   # Height above the ball
var look_smooth_speed = 5.0  # How smoothly the camera looks at the target

# Reference to the red ball (will be set from _ready)
var red_ball = null

func _ready():
	# Find the red ball node in the scene
	red_ball = get_parent().get_node("RedSphere")
	if red_ball == null:
		push_error("Could not find RedSphere node for camera to follow")

func _process(delta):
	if red_ball != null:
		# Calculate desired camera position IN FRONT and above the ball
		var desired_position = red_ball.transform.origin + Vector3(0, 0, follow_distance)
		desired_position.y += follow_height
		
		# Smoothly move camera to desired position
		transform.origin = transform.origin.lerp(desired_position, delta * look_smooth_speed)
		
		# Make camera look slightly down at the red ball for better third-person view
		var look_target = red_ball.transform.origin + Vector3(0, -1, 0)  # Look slightly down
		look_at(look_target, Vector3.UP)