extends StateNode

@export var work_speed: float = 1.5
@export var target_threshold: float = 1.0

var _target_position: Vector3 = Vector3.ZERO
var _working: bool = false
var _work_timer: float = 0.0

func enter(_data: Dictionary = {}) -> void:
	_pick_new_target()
	_working = false

func physics_update(delta: float) -> void:
	var npc: NpcPeasant = owner as NpcPeasant
	if not npc: return
	
	if _working:
		_work_timer -= delta
		if _work_timer <= 0:
			_pick_new_target()
			_working = false
		return

	var distance: float = npc.global_position.distance_to(_target_position)
	if distance < target_threshold:
		_start_working()
		return
		
	var direction: Vector3 = (_target_position - npc.global_position).normalized()
	direction.y = 0.0
	npc.velocity = direction * work_speed
	if direction.length_squared() > 0.001:
		npc.look_at(npc.global_position + direction, Vector3.UP)

func _pick_new_target() -> void:
	var npc: NpcPeasant = owner as NpcPeasant
	if not npc: return
	
	if npc.current_fief:
		# Pick random point in fief radius
		var radius: float = 15.0 # Slightly smaller than Fief collision
		var angle: float = randf() * PI * 2
		var dist: float = randf() * radius
		var offset: Vector3 = Vector3(cos(angle) * dist, 0, sin(angle) * dist)
		_target_position = npc.current_fief.global_position + offset
	else:
		# Just wander if no fief
		var offset: Vector3 = Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
		_target_position = npc.global_position + offset

func _start_working() -> void:
	_working = true
	_work_timer = randf_range(5.0, 10.0)
	var npc: NpcPeasant = owner as NpcPeasant
	if npc and npc.visuals:
		npc.visuals.play_animation("Take 001") # Placeholder for work anim
	npc.velocity = Vector3.ZERO
