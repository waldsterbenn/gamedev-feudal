# ============================================================================
# LEGACY CODE — outside the Management module and Terrain generator.
# Retained for now; scheduled for refactor or removal. Do not extend.
# ============================================================================
extends StateNode

@export var move_speed: float = 2.0
@export var waypoint_threshold: float = 0.5

var _current_waypoint_idx: int = 0
var _target_position: Vector3 = Vector3.ZERO

func enter(_data: Dictionary = {}) -> void:
	var npc: NpcPeasant = owner as NpcPeasant
	if not npc:
		state_machine.change_state_by_path("Idle")
		return
	if npc.visuals:
		npc.visuals.play_animation("Take 001")
	var points: Array[Vector3] = npc.patrol_points
	if points.is_empty():
		state_machine.change_state_by_path("Idle")
		return
	_target_position = points[_current_waypoint_idx]

func physics_update(_delta: float) -> void:
	var npc: NpcPeasant = owner as NpcPeasant
	if not npc:
		state_machine.change_state_by_path("Idle")
		return
	var distance: float = npc.global_position.distance_to(_target_position)
	if distance < waypoint_threshold:
		_advance_waypoint()
		return
	var direction: Vector3 = (_target_position - npc.global_position).normalized()
	direction.y = 0.0
	
	if not npc.is_on_floor():
		npc.velocity.y += -9.8 * _delta
	else:
		npc.velocity.y = 0.0

	if direction.length_squared() > 0.001:
		npc.look_at(npc.global_position + direction, Vector3.UP)
		var horizontal_vel: Vector3 = direction * move_speed
		npc.velocity.x = horizontal_vel.x
		npc.velocity.z = horizontal_vel.z
	else:
		npc.velocity.x = 0.0
		npc.velocity.z = 0.0

func _advance_waypoint() -> void:
	var npc: NpcPeasant = owner as NpcPeasant
	if not npc:
		return
	var points: Array[Vector3] = npc.patrol_points
	if points.is_empty():
		state_machine.change_state_by_path("Idle")
		return
	_current_waypoint_idx = (_current_waypoint_idx + 1) % points.size()
	_target_position = points[_current_waypoint_idx]
