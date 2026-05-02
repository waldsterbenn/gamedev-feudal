extends Node3D

@onready var world_env: WorldEnvironment = $WorldEnvironment
@onready var sun: DirectionalLight3D = $DirectionalLight3D

func _ready() -> void:
	EventBus.season_changed.connect(_on_season_changed)
	_apply_season_visuals(GameManager.current_season)

func _on_season_changed(season_index: int) -> void:
	_apply_season_visuals(season_index)

func _apply_season_visuals(index: int) -> void:
	if not world_env or not sun: return
	
	var env: Environment = world_env.environment
	if not env: return
	
	match index:
		0: # Spring
			sun.light_color = Color(1.0, 1.0, 0.9)
			sun.light_energy = 1.0
			env.adjustment_saturation = 1.0
			env.adjustment_brightness = 1.0
		1: # Summer
			sun.light_color = Color(1.0, 1.0, 0.8)
			sun.light_energy = 1.2
			env.adjustment_saturation = 1.1
			env.adjustment_brightness = 1.05
		2: # Autumn
			sun.light_color = Color(1.0, 0.8, 0.6)
			sun.light_energy = 0.8
			env.adjustment_saturation = 1.2
			env.adjustment_brightness = 0.9
		3: # Winter
			sun.light_color = Color(0.8, 0.9, 1.0)
			sun.light_energy = 0.6
			env.adjustment_saturation = 0.7
			env.adjustment_brightness = 0.8
	
	# Enable adjustments if they aren't already
	env.adjustment_enabled = true
