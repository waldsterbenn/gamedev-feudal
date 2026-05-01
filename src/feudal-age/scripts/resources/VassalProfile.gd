class_name VassalProfile
extends Resource

@export var vassal_name: String = "Generic Vassal"
@export var opinion: int = 0      # -100 to 100
@export var loyalty: int = 50     # 0 to 100
@export var fear: int = 0         # 0 to 100
@export var obligations: int = 50 # 0 to 100

@export var traits: Array[String] = []

func change_opinion(delta: int) -> void:
	opinion = clampi(opinion + delta, -100, 100)
	_update_loyalty()

func change_fear(delta: int) -> void:
	fear = clampi(fear + delta, 0, 100)
	_update_loyalty()

func _update_loyalty() -> void:
	# Simplified formula: Loyalty is a mix of opinion and fear, weighted by traits
	var base_loyalty: float = (opinion + 100) / 2.0
	
	if "Ambitious" in traits:
		base_loyalty *= 0.8
	if "Loyal" in traits:
		base_loyalty *= 1.2
		
	# Fear can force loyalty even if opinion is low
	var fear_factor: float = fear * 0.5
	
	loyalty = clampi(int(base_loyalty + fear_factor), 0, 100)
