extends Node

var management_api: Node = null
var terrain_manager: Node = null

func register_management_service(api: Node) -> void:
	management_api = api

func get_management_service() -> Node:
	assert(management_api != null, "Management API requested before initialization!")
	return management_api

func register_terrain_service(tm: Node) -> void:
	terrain_manager = tm

func get_terrain_service() -> Node:
	return terrain_manager
