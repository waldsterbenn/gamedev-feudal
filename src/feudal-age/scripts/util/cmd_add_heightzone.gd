extends SceneTree

## Automated HeightZone Addition Utility
## Usage: 
## 1. AI Agent uses 'replace' to update CONFIGURATION.
## 2. Execute: godot --headless --path src/feudal-age -s scripts/util/cmd_add_heightzone.gd

const CONFIGURATION = {
	"label": "Meadow Grass",
	"texture_id": 0,
	"min_height": 100.0,
	"max_height": 120.0,
	"scene_path": "res://scenes/TerrainManager.tscn"
}

func _init() -> void:
	print("Adding HeightZone: ", CONFIGURATION.label)
	
	var scene: PackedScene = load(CONFIGURATION.scene_path)
	if not scene:
		print("ERROR: Could not load scene at ", CONFIGURATION.scene_path)
		quit(1)
		return
		
	var root: Node = scene.instantiate()
	var generator: TextureMapGenerator = root.find_child("TextureMapGenerator", true, false)
	
	if not generator:
		print("ERROR: TextureMapGenerator node not found in scene.")
		root.free()
		quit(1)
		return
		
	# Create and configure the new resource
	var new_zone := HeightZone.new()
	new_zone.label = CONFIGURATION.label
	new_zone.texture_id = CONFIGURATION.texture_id
	new_zone.min_height = CONFIGURATION.min_height
	new_zone.max_height = CONFIGURATION.max_height
	
	# Add to array
	generator.height_zones.append(new_zone)
	print("Current zone count: ", generator.height_zones.size())
	
	# Save the scene back
	var packed_scene := PackedScene.new()
	var result: Error = packed_scene.pack(root)
	if result == OK:
		result = ResourceSaver.save(packed_scene, CONFIGURATION.scene_path)
		if result == OK:
			print("SUCCESS: Scene saved with new HeightZone.")
		else:
			print("ERROR: Failed to save scene. Error code: ", result)
	else:
		print("ERROR: Failed to pack scene. Error code: ", result)
		
	root.free()
	quit()
