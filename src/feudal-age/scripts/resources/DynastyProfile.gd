class_name DynastyProfile
extends Resource

@export var family_name: String = "of the Vale"
@export var crest_color: Color = Color.DARK_RED
@export var founding_year: int = 1200

@export var members: Array[VassalProfile] = []
@export var head_of_house: VassalProfile

func add_member(profile: VassalProfile) -> void:
	if not members.has(profile):
		members.append(profile)

func remove_member(profile: VassalProfile) -> void:
	members.erase(profile)
