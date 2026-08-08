# NOTE: This is a temporary measure and acts as a stand-in for a proper procedural world generator.
extends Node

@onready var coordinator: ZoneCoordinator = $"../ZoneCoordinator"

func _ready() -> void:
	# Spawning data hardcoded as a temporary measure
	var zones_to_spawn = [
		{
			"id": 1,
			"name": "Ironwood Hollow",
			"pos": Vector3(12, 79.129, 12),
			"fertilities": {"Timber": 0.8, "Cereals": 0.3, "Berries": 0.5, "Mushrooms": 0.4}
		},
		{
			"id": 2,
			"name": "Millstone Ridge",
			"pos": Vector3(40, 78.5, 20),
			"fertilities": {"Timber": 0.6, "Cereals": 0.6, "Berries": 0.3, "Mushrooms": 0.2}
		},
		{
			"id": 3,
			"name": "Ashfen Crossing",
			"pos": Vector3(20, 78.0, 45),
			"fertilities": {"Timber": 0.5, "Cereals": 0.4, "Berries": 0.6, "Mushrooms": 0.6}
		}
	]
	
	for data in zones_to_spawn:
		# Create the ZoneNode resource dynamically
		var node = ZoneNode.new()
		node.node_id = data["id"]
		node.node_name = data["name"]
		node.fertilities = data["fertilities"]
		node.current_tier = ZoneNode.SettlementTier.WILDERNESS
		
		# Create visual representation through Coordinator
		var anchor = coordinator.create_zone_anchor(data["id"], data["pos"])
		anchor.initialize(node)
