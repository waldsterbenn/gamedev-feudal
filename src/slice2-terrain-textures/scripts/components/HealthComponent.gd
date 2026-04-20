class_name HealthComponent
extends Node
# HealthComponent.gd - Manages health and damage for a node

# 1. signals
signal health_changed(current_health: float, max_health: float)
signal health_depleted
signal damaged(amount: float)
signal healed(amount: float)

# 2. exports
@export var max_health: float = 100.0
@export var initial_health: float = 100.0

# 3. private vars
var _current_health: float

# 4. built-in callbacks
func _ready() -> void:
	_current_health = initial_health
	health_changed.emit(_current_health, max_health)

# 5. public functions
func take_damage(amount: float) -> void:
	if amount <= 0:
		return
	
	_current_health = clampf(_current_health - amount, 0, max_health)
	damaged.emit(amount)
	health_changed.emit(_current_health, max_health)
	
	if _current_health <= 0:
		health_depleted.emit()

func heal(amount: float) -> void:
	if amount <= 0:
		return
	
	_current_health = clampf(_current_health + amount, 0, max_health)
	healed.emit(amount)
	health_changed.emit(_current_health, max_health)

func get_health() -> float:
	return _current_health

func get_health_percent() -> float:
	return _current_health / max_health
