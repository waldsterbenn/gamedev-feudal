extends Node

func initialize_module() -> void:
	print("ManagementModule: Initializing economic simulation...")

func process_tick(context: Resource) -> void:
	if not context or not "world_nodes" in context:
		return
	for node_id in context.world_nodes:
		var node: ZoneNode = context.world_nodes[node_id]
		node.process_management_tick()

func get_save_snapshot() -> Dictionary:
	return {}
