# NOTE: This is a temporary measure and acts as a stand-in for a proper procedural world generator.
extends Node

@onready var zone_coordinator: ZoneCoordinator = $"../ZoneCoordinator"
@onready var npc_coordinator: NPCCoordinator = $"../NPCCoordinator"

func _ready() -> void:
	# Spawning data hardcoded as a temporary measure
	var zones_to_spawn = [
		{
			"id": 1,
			"name": "Ironwood Hollow",
			"pos": Vector3(12.0, 79.129, 12.0),
			"fertilities": {"Timber": 0.8, "Cereals": 0.3, "Berries": 0.5, "Mushrooms": 0.4},
			"initial_populants": [
				{"offset": Vector3(1.5, 0.0, 1.5), "qualification": "woodcutter"},
				{"offset": Vector3(-2.0, 0.0, 1.0), "qualification": "unskilled"}
			]
		},
		{
			"id": 2,
			"name": "Millstone Ridge",
			"pos": Vector3(40.0, 78.5, 20.0),
			"fertilities": {"Timber": 0.6, "Cereals": 0.6, "Berries": 0.3, "Mushrooms": 0.2},
			"initial_populants": [
				{"offset": Vector3(0.0, 0.0, 2.0), "qualification": "forager"}
			]
		},
		{
			"id": 3,
			"name": "Ashfen Crossing",
			"pos": Vector3(20.0, 78.0, 45.0),
			"fertilities": {"Timber": 0.5, "Cereals": 0.4, "Berries": 0.6, "Mushrooms": 0.6},
			"initial_populants": [
				{"offset": Vector3(-1.0, 0.0, -1.5), "qualification": "forager"},
				{"offset": Vector3(2.5, 0.0, -0.5), "qualification": "unskilled"}
			]
		}
	]

	for data in zones_to_spawn:
		# 1. Create domain Resource for the zone
		var zone_node = ZoneNode.new()
		zone_node.node_id = data["id"]
		zone_node.node_name = data["name"]
		zone_node.fertilities = data["fertilities"]
		zone_node.current_tier = ZoneNode.SettlementTier.WILDERNESS

		# 2. Spawn visual anchor via ZoneCoordinator
		var zone_pos: Vector3 = data["pos"]
		var anchor = zone_coordinator.create_zone_anchor(data["id"], zone_pos)
		anchor.initialize(zone_node)

		# 3. Spawn NPCs via NPCCoordinator and link to Management Module
		if data.has("initial_populants"):
			for pop_data in data["initial_populants"]:
				var spawn_pos: Vector3 = zone_pos + pop_data["offset"]
				var spawn_transform := Transform3D(Basis.IDENTITY, spawn_pos)
				
				# Coordinator instantiates physical Godot NPC scene and syncs IDs
				var npc: NPC = npc_coordinator.create_npc(spawn_transform)
				
				if npc:
					var pop_comp = npc.management_comp
					if pop_comp:
						pop_comp.qualification_profile = pop_data.get("qualification", "unskilled")
						
						# Sync domain assignment using the unified Coordinator ID
						var mgmt_api = ServiceLocator.get_management_service()
						if mgmt_api:
							mgmt_api.recruit_populant_to_faction(npc.id, "player")
							mgmt_api.assign_populant_to_node(npc.id, data["id"])
