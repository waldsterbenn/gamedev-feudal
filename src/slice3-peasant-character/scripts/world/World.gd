extends Node3D
# World.gd - Manages world-level systems

# 1. onready
@onready var navigation_region: NavigationRegion3D = $NavigationRegion3D

# 2. built-in callbacks
func _ready() -> void:
	if navigation_region:
		# Create a simple plane navmesh manually since runtime baking is unreliable
		var nav_mesh: NavigationMesh = NavigationMesh.new()
		var plane_mesh: PlaneMesh = PlaneMesh.new()
		plane_mesh.size = Vector2(48, 48)
		nav_mesh.create_from_mesh(plane_mesh)
		navigation_region.navigation_mesh = nav_mesh
		EventBus.message_logged.emit("Navigation mesh ready", "info")
