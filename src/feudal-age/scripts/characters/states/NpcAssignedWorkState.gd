extends StateNode
class_name NpcAssignedWorkState

## State entered when an NPC has been assigned to a ZoneNode by the ManagementAPI.
## Steers the NPC to their workplace target, then idles in place until day_changed fires.

@export var move_speed: float = 1.5
@export var arrival_threshold: float = 1.2

var _target_position: Vector3 = Vector3.ZERO
var _arrived: bool = false
var _management_comp: ManagementPopulantComponent = null

func enter(_data: Dictionary = {}) -> void:
	_arrived = false
	_management_comp = owner.get_node_or_null("ManagementPopulantComponent")
	_refresh_target()
	EventBus.day_changed.connect(_on_day_changed)

func exit() -> void:
	if EventBus.day_changed.is_connected(_on_day_changed):
		EventBus.day_changed.disconnect(_on_day_changed)

func physics_update(delta: float) -> void:
	var npc: NpcPeasant = owner as NpcPeasant
	if not npc:
		return

	# If we have no assignment any more, fall back to idle
	if _management_comp and not _management_comp.is_assigned():
		state_machine.change_state_by_path("Idle")
		return

	if _arrived:
		# Stand still at worksite
		npc.velocity = Vector3.ZERO
		return

	var distance: float = npc.global_position.distance_to(_target_position)
	if distance < arrival_threshold:
		_arrived = true
		npc.velocity = Vector3.ZERO
		if npc.visuals:
			npc.visuals.play_animation("Take 001") # placeholder work animation
		return

	# Navigate toward target
	var direction: Vector3 = (_target_position - npc.global_position).normalized()
	direction.y = 0.0

	if not npc.is_on_floor():
		npc.velocity.y += -9.8 * delta
	else:
		npc.velocity.y = 0.0

	npc.velocity.x = direction.x * move_speed
	npc.velocity.z = direction.z * move_speed

	if direction.length_squared() > 0.001:
		npc.look_at(npc.global_position + direction, Vector3.UP)

func _refresh_target() -> void:
	if not _management_comp:
		return

	# Use the explicit workplace marker if one has been set
	if _management_comp.current_3d_workplace_target != null:
		_target_position = _management_comp.current_3d_workplace_target.global_position
		return

	# Fallback: query ManagementAPI for assignment data
	var api = ServiceLocator.get_management_service()
	if api:
		var assignment = api.get_character_assignment(_management_comp.character_id)
		if assignment.has("work_target_position"):
			_target_position = assignment["work_target_position"]

func _on_day_changed(_new_day: int) -> void:
	# Re-evaluate target each day so workers respond to reallocation
	_arrived = false
	_refresh_target()
