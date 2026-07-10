extends Node

var management_api: Node = null

func register_management_service(api: Node) -> void:
	management_api = api

func get_management_service() -> Node:
	assert(management_api != null, "Management API requested before initialization!")
	return management_api
