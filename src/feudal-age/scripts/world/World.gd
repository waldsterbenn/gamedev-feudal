extends Node3D

@onready var navigation_region: NavigationRegion3D = $NavigationRegion3D

func _ready() -> void:
	if navigation_region:
		var nav_mesh: NavigationMesh = NavigationMesh.new()
		var plane_mesh: PlaneMesh = PlaneMesh.new()
		plane_mesh.size = Vector2(48, 48)
		nav_mesh.create_from_mesh(plane_mesh)
		navigation_region.navigation_mesh = nav_mesh
		EventBus.message_logged.emit("Navigation mesh ready", "info")
