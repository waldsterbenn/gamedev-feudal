@tool
extends Node
## Autoload that registers HTerrain resource format loaders at runtime.
## This is required for .hterrain files to load properly outside the editor.

var _loader: ResourceFormatLoader = null
var _saver: ResourceFormatSaver = null


func _ready() -> void:
	# Only register if not in editor (editor plugin handles its own registration)
	if not Engine.is_editor_hint():
		_loader = HTerrainDataLoader.new()
		ResourceLoader.add_resource_format_loader(_loader)
		_saver = HTerrainDataSaver.new()
		ResourceSaver.add_resource_format_saver(_saver)


func _exit_tree() -> void:
	if _loader != null:
		ResourceLoader.remove_resource_format_loader(_loader)
		_loader = null
	if _saver != null:
		ResourceSaver.remove_resource_format_saver(_saver)
		_saver = null
