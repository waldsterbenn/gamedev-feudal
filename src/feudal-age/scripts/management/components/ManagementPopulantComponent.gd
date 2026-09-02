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
	_registered_api = ServiceLocator.get_management_service()
	if _registered_api:
		_registered_api.register_populant_component(self)

func _exit_tree() -> void:
	# Unregister when the NPC leaves the scene tree
	var api = _registered_api if _registered_api else ServiceLocator.get_management_service()
	if api:
		api.unregister_populant_component(character_id)

## Re-key the registration after the ID was corrected post-_ready().
## NPC.gd assigns Coordinator IDs before add_child() for runtime-created
## components, but scene-defined components may be re-keyed afterwards.
func notify_character_id_changed(old_id: int) -> void:
	if _registered_api == null:
		return
	_registered_api.rekey_populant_registration(old_id, self)

# The API instance this component registered with (null before _ready()).
var _registered_api: Node = null

## Returns true if this populant is actively assigned to a lord and a node
func is_assigned() -> bool:
	return serving_lord_id != "none" and assigned_node_id != -1
