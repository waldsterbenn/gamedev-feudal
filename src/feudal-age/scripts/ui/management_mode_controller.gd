extends Node

## Handles toggling the management overlay on/off (Tab key).
## Broadcasts EventBus.ui.management_mode_changed so all ZoneAnchor3D nodes
## enable or disable their collision and visual ring in one shot.

var _management_active: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_management"):
		_management_active = not _management_active
		EventBus.ui.management_mode_changed.emit(_management_active)

		# Release the mouse when inspecting so the player can click zone anchors,
		# re-capture when returning to normal play
		if _management_active:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
