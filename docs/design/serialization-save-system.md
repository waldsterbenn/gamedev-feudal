# Part 11: Technical Design Document (TDD) — Serialization & Save System

This document outlines the architecture for the serialization engine using Godot 4’s native **Custom Resource Architecture**. This system eliminates data-parsing bottlenecks and manual string conversions by leveraging type-safe storage files. Variables marked with `@export` are automatically handled with absolute type safety, allowing coordinates (`Vector3`), nested data blocks (`Dictionary`), and complex object states to save natively.

---

## 1. Resource Architecture Topography

The serialization engine packages game states into a tree of dedicated, structural data classes rather than text-based object streams.

```
[SaveLoadService (Autoload)] 
     ├── Collects and feeds SaveSlotData resources
     └── Calls ResourceSaver / ResourceLoader singletons
          │
          └── [SaveSlotData (Resource Class)]
               ├── metadata: SaveMetadata (Nested Resource)
               ├── ledger_data: Dictionary (Headless Fief State)
               └── entity_snapshots: Array[NPCEntitySnapshot] (Nested Resources)

```

---

## 2. Component & Core Script Specifications

### 2.1 The Data Structure Resources

These files serve as pure data definitions. They carry no logic processes, only strongly typed `@export` parameters.

```gdscript
# save_metadata.gd
extends Resource
class_name SaveMetadata

@export var timestamp: float
@export var game_version: String
@export var in_game_time: float

```

```gdscript
# npc_entity_snapshot.gd
extends Resource
class_name NPCEntitySnapshot

@export var scene_file_path: String
@export var populant_id: int
@export var global_position: Vector3
@export var rotation_y: float
@export var linear_velocity_y: float

```

```gdscript
# save_slot_data.gd
extends Resource
class_name SaveSlotData

@export var metadata: SaveMetadata
@export var ledger_data: Dictionary
@export var entity_snapshots: Array[NPCEntitySnapshot] = []

```

---

### 2.2 The Global Save/Load Service

The coordinator utilizes the `ResourceSaver` and `ResourceLoader` APIs to safely commit and rebuild the state graph in a single unified operation.

```gdscript
# save_load_service.gd
extends Node
class_name SaveLoadService

const SAVE_PATH_TEMPLATE: String = "user://saves/slot_%d.tres"

## Master orchestration pipeline for persisting state fields to disk
func execute_save_game(slot_id: int) -> void:
	# 1. Freeze time tracking mechanics to secure a clean snapshot
	var clock = ServiceLocator.get_time_service()
	if clock: clock.set_process(false)
	
	# 2. Instantiate data resources
	var slot_data = SaveSlotData.new()
	
	var meta = SaveMetadata.new()
	meta.timestamp = Time.get_unix_time_from_system()
	meta.game_version = "1.0.0"
	meta.in_game_time = TimeEngine.absolute_elapsed_seconds
	slot_data.metadata = meta
	
	# 3. Extract Headless Ledger Snapshot
	var management_api = ServiceLocator.get_management_service()
	if management_api:
		slot_data.ledger_data = management_api.serialize_ledger_state()
		
	# 4. Harvest Spatial Entities
	var saving_nodes = get_tree().get_nodes_in_group("persist_entities")
	for node in saving_nodes:
		if node.has_method("get_save_resource"):
			var npc_snap: NPCEntitySnapshot = node.get_save_resource()
			slot_data.entity_snapshots.append(npc_snap)
			
	# 5. Commit to Disk natively via Godot Saver API
	var target_path = SAVE_PATH_TEMPLATE % slot_id
	_ensure_directory_exists()
	
	# Note: Use FLAG_BUNDLE_RESOURCES to encapsulate sub-resources into a clean, single save file
	ResourceSaver.save(slot_data, target_path, ResourceSaver.FLAG_BUNDLE_RESOURCES)
	
	# 6. Unfreeze execution timelines
	if clock: clock.set_process(true)

## Master orchestration pipeline for reconstructing state parameters from disk
func execute_load_game(slot_id: int) -> void:
	var target_path = SAVE_PATH_TEMPLATE % slot_id
	if not ResourceLoader.exists(target_path):
		return
		
	# Load directly back into a strongly typed data container
	var slot_data := ResourceLoader.load(target_path) as SaveSlotData
	if not slot_data:
		return

	# 1. Purge current spatial gameplay tree entities completely
	get_tree().call_group("persist_entities", "queue_free")
	
	# 2. Re-establish global time tracking points
	TimeEngine.absolute_elapsed_seconds = slot_data.metadata.in_game_time
	
	# 3. Reconstruct Headless Ledger Backend first
	var management_api = ServiceLocator.get_management_service()
	if management_api:
		management_api.deserialize_ledger_state(slot_data.ledger_data)
		
	# 4. Spawn 3D World Entities and inject their corresponding Resource snapshots
	for snap in slot_data.entity_snapshots:
		var scene_resource = load(snap.scene_file_path)
		var instance = scene_resource.instantiate()
		
		get_tree().current_scene.add_child(instance)
		
		if instance.has_method("load_save_resource"):
			instance.load_save_resource(snap)

func _ensure_directory_exists() -> void:
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")

```

---

### 2.3 Physical 3D Agent Persistence Implementation

Physical entities plug directly into this registry framework. Instead of manual string formatting, agents interact with the structured resource parameters.

```gdscript
# spatial_npc_agent.gd
extends CharacterBody3D

@onready var populant_component: ManagementPopulantComponent = $ManagementPopulantComponent

func _ready() -> void:
	add_to_group("persist_entities")

## Interface method harvested by the global save service
func get_save_resource() -> NPCEntitySnapshot:
	var snapshot = NPCEntitySnapshot.new()
	
	snapshot.scene_file_path = scene_file_path
	snapshot.populant_id = populant_component.populant_id
	snapshot.global_position = global_position
	snapshot.rotation_y = global_rotation.y
	snapshot.linear_velocity_y = velocity.y
	
	return snapshot

## Interface method target injected by the global load service
func load_save_resource(snapshot: NPCEntitySnapshot) -> void:
	# Native assignments maintain strict compiler-checked properties
	global_position = snapshot.global_position
	global_rotation.y = snapshot.rotation_y
	velocity.y = snapshot.linear_velocity_y
	
	populant_component.populant_id = snapshot.populant_id
	
	# Rebind dependencies safely
	populant_component.rebind_to_management_api_context()

```

---

## 3. Data Integrity & Validation Safeguards

### 3.1 Serialization Storage Formats

Development snapshots are tracked via Godot's text resource configuration format (`.tres`), which provides clean, human-readable verification parameters for structural debugging. For production distribution, swapping the file extension target to binary format (`.res`) compresses file sizes and minimizes file-load latency.

### 3.2 Modding & Lifecycle Extensibility

Using resources keeps data schemas decoupled. If future updates introduce new attributes (e.g., dynamic faction standing or distinct trait flags), they are added as parameters to the corresponding resource scripts. The native `ResourceLoader` assigns default fallback initial values to parameters omitted in older save files, allowing backwards compatibility.