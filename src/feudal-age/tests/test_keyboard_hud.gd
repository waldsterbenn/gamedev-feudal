extends SceneTree
func _init():
	# Load world scene directly
	var s = load("res://scenes/world/World.tscn")
	if s == null:
		print("FAIL: World.tscn not found or broken reference")
		quit(1)
	var root_node = s.instantiate()
	root.add_child(root_node)
	# Verify keyboard selector and HUD nodes exist
	var ks = root.get_node_or_null("KeyboardZoneSelector")
	var hud = root.get_node_or_null("UICoordinator/HUDInstructions")
	print("KeyboardZoneSelector: ", "PASS" if ks != null else "FAIL")
	print("HUDInstructions: ", "PASS" if hud != null else "FAIL")
	if ks != null and hud != null:
		print("PASS: keyboard + HUD loaded")
	else:
		print("FAIL: missing nodes")
	quit(0 if (ks != null and hud != null) else 1)
