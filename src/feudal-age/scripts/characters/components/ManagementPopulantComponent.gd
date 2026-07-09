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
