extends Node

var management_api: ManagementAPI = null

func register_management_service(api: ManagementAPI) -> void:
	management_api = api

func get_management_service() -> ManagementAPI:
	assert(management_api != null, "Management API requested before initialization!")
	return management_api
