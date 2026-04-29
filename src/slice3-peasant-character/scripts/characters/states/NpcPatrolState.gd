class_name NpcPatrolState
extends State
# NpcPatrolState.gd - Patrol behavior for NPC peasant
# Uses direct waypoint movement (no navmesh required for slice demo)

# 1. exports
@export var move_speed: float = 2.0
@export var waypoint_reached_threshold: float = 0.5

# 2. private vars
var _current_waypoint_index: int = 0
var _target_position: Vector3 = Vector3.ZERO

# 3. virtual methods
func enter(_data: Dictionary = {}) -> void:
	var npc: NpcPeasant = owner as NpcPeasant
	if not npc:
		return
	if npc.visuals:
		npc.visuals.play_animation("Take 001")
	var points: Array[Vector3] = npc.patrol_points
	if points.is_empty():
		state_machine.change_state_by_path("Idle")
		return
	_target_position = points[_current_waypoint_index]

func physics_update(delta: float) -> void:
	var npc: NpcPeasant = owner as NpcPeasant
	if not npc:
		state_machine.change_state_by_path("Idle")
		return
	
	var distance_to_target: float = npc.global_position.distance_to(_target_position)
	if distance_to_target < waypoint_reached_threshold:
		_advance_waypoint()
		return
	
	var direction: Vector3 = (_target_position - npc.global_position).normalized()
	direction.y = 0.0
	
	if direction.length_squared() > 0.001:
		npc.look_at(npc.global_position + direction, Vector3.UP)
		npc.velocity = direction * move_speed
	else:
		npc.velocity = Vector3.ZERO

# 4. private functions
func _advance_waypoint() -> void:
	var npc: NpcPeasant = owner as NpcPeasant
	if not npc:
		return
	var points: Array[Vector3] = npc.patrol_points
	if points.is_empty():
		state_machine.change_state_by_path("Idle")
		return
	_current_waypoint_index = (_current_waypoint_index + 1) % points.size()
	_target_position = points[_current_waypoint_index]
