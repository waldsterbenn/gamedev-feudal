extends Node
class_name ManagementPopulantComponent

@export var character_id: int

# Faction & Residency State (Exposed to GOAP and Management Systems)
@export var serving_lord_id: String = "none" # e.g., "player", "rival_lord_1", "none"
@export var assigned_node_id: int = -1       # Coordinates where this Populant resides

# The skill string this Populant registers into the matching pool
@export var qualification_profile: String = "unskilled" 

# Reference to the physical 3D marker on Terrain3D where the NPC travels to execute jobs
var current_3d_workplace_target: Marker3D = null

func _ready() -> void:
	# Register with ManagementAPI as soon as this component is active
	var api = ServiceLocator.get_management_service()
	if api:
		api.register_populant_component(self)

func _exit_tree() -> void:
	# Unregister when the NPC leaves the scene tree
	var api = ServiceLocator.get_management_service()
	if api:
		api.unregister_populant_component(character_id)

## Returns true if this populant is actively assigned to a lord and a node
func is_assigned() -> bool:
	return serving_lord_id != "none" and assigned_node_id != -1
