# Technical Design Document (TDD) — NPC Coordinator Implementation Plan

> **Last Updated:** 2026-08-10

## 1. Purpose & Scope

This document defines the final, production-ready technical design and implementation plan for the `NPCCoordinator`.

Following design feedback, we have simplified the architecture by **bypassing the inheritance model**. Rather than maintaining a base class and sub-classes, we are renaming the existing `NpcPeasant` class and scene to a single concrete `NPC` class/scene. This removes class hierarchy complexity while fulfilling all game loop requirements.

1. **Exact Directory Paths:** Conforms strictly to `src/feudal-age/scripts/...` layout conventions and PascalCase naming rules.
2. **Simplified Class Structure:** `NpcPeasant.gd` is renamed to `NPC.gd` (and scene to `NPC.tscn`). It inherits directly from `CharacterBody3D`.
3. **State Updates:** All character state scripts are updated to cast to `NPC` instead of `NpcPeasant`.
4. **Single Source of Truth for ID Resolution:** Resolves the ID split-brain issue by using the `NPCCoordinator`-assigned integer ID as the primary key across both the **Spatial/Scene Context** and the **Simulation/Management Context** (`ManagementPopulantComponent.character_id`).

---

## 2. Entity Class & Prefab Architecture

### 2.1 Concrete Class: `NPC.gd`

**File Path:** `res://src/feudal-age/scripts/characters/NPC.gd` (Renamed from `NpcPeasant.gd`)

Inherits directly from `CharacterBody3D`. It serves as the single concrete class for physical NPCs. It safely fetches or creates `ManagementPopulantComponent` dynamically and handles ID alignment for both coordinator-spawned and manually scene-placed test nodes.

```gdscript
class_name NPC
extends CharacterBody3D

signal waypoint_reached(waypoint_index: int)

@export var patrol_points: Array[Vector3] = []
@export var npc_name: String = "Peasant"

## Coordinator-assigned tracking ID. Set at runtime by NPCCoordinator.
var id: int = -1

var management_comp: ManagementPopulantComponent = null

@onready var state_m: StateMachine = $StateMachine
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var visuals: PeasantCharacter = $PeasantCharacter
@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var status_label: Label3D = $StatusLabel

func _ready() -> void:
	# Retrieve or create component dynamically to ensure backward compatibility
	management_comp = get_node_or_null("ManagementPopulantComponent") as ManagementPopulantComponent
	if not management_comp:
		management_comp = ManagementPopulantComponent.new()
		management_comp.name = "ManagementPopulantComponent"
		add_child(management_comp)

	# Align IDs: Preserve Coordinator-assigned ID if available, else fall back to name.hash()
	if management_comp.character_id <= 0:
		management_comp.character_id = id if id != -1 else name.hash()

	if interactable_component:
		interactable_component.interacted.connect(_on_interacted)

	if state_m:
		state_m.state_changed.connect(_on_state_changed)
		_on_state_changed(state_m.initial_state.name if state_m.initial_state else "None")

	print("NPC initialized: ", npc_name)

func _physics_process(_delta: float) -> void:
	move_and_slide()

func _on_state_changed(state_name: String) -> void:
	if status_label:
		status_label.text = npc_name + " (" + state_name + ")"

func _on_interacted(_interactor: Node3D) -> void:
	if state_m:
		state_m.change_state_by_path("Interact")

## Called by external systems (ManagementAPI, player UI) to put the NPC into assigned work mode.
func assign_to_work() -> void:
	if state_m:
		state_m.change_state_by_path("AssignedWork")
```

---

### 2.2 Modular Scene Hierarchy (`NPC.tscn`)

**File Path:** `res://src/feudal-age/scenes/characters/NPC.tscn` (Renamed from `NpcPeasant.tscn`)

```
NPC (CharacterBody3D)                           ← script: NPC.gd (extends CharacterBody3D)
├── CollisionShape3D
├── MeshInstance3D
├── StateMachine (Node)
├── NavigationAgent3D (Node3D)
├── PeasantCharacter (Node3D)
├── InteractableComponent (Area3D)
├── StatusLabel (Label3D)
└── ManagementPopulantComponent (Node)          ← script: ManagementPopulantComponent.gd
```

---

## 3. Scene-Tree Topology

In the active `World` scene, coordinators and their target container nodes reside as direct siblings under the world root.

```
World (Node3D)
├── WorldInitializer   (Node)     ← script: WorldInitializer.gd
├── ZoneCoordinator    (Node)     ← script: ZoneCoordinator.gd
├── ZoneContainer      (Node3D)   ← plain organizational container
├── NPCCoordinator     (Node)     ← script: NPCCoordinator.gd
└── NPCContainer       (Node3D)   ← plain organizational container
    ├── NPC            (CharacterBody3D) [id: 1, character_id: 1]
    ├── NPC            (CharacterBody3D) [id: 2, character_id: 2]
    └── NPC            (CharacterBody3D) [id: 3, character_id: 3]
```

---

## 4. Implementation Details

### 4.1 Coordinator Script (`NPCCoordinator.gd`)

**File Path:** `res://src/feudal-age/scripts/world/NPCCoordinator.gd`

```gdscript
class_name NPCCoordinator
extends Node

@export var npc_prefab: PackedScene
@export var container_path: NodePath

var _container: Node
var _tracked_npcs: Dictionary = {} # int (id) -> NPC
var _next_id: int = 1

func _ready() -> void:
	if container_path.is_empty():
		push_error("NPCCoordinator: container_path is not set.")
		return
	_container = get_node(container_path)

## Instantiates an NPC prefab, syncs IDs across contexts, attaches to container, and returns instance.
func create_npc(global_transform: Transform3D = Transform3D.IDENTITY) -> NPC:
	if not npc_prefab:
		push_error("NPCCoordinator: npc_prefab is not assigned in the Inspector.")
		return null
	if not _container:
		push_error("NPCCoordinator: container node is invalid.")
		return null

	var npc_instance: NPC = npc_prefab.instantiate() as NPC
	if not npc_instance:
		push_error("NPCCoordinator: Failed to instantiate NPC prefab as NPC class.")
		return null

	# Assign stable Coordinator ID
	var assigned_id: int = _next_id
	_next_id += 1
	npc_instance.id = assigned_id

	# Single Source of Truth: Sync Management Component ID prior to _ready() execution
	var management_comp = npc_instance.get_node_or_null("ManagementPopulantComponent") as ManagementPopulantComponent
	if management_comp:
		management_comp.character_id = assigned_id

	_tracked_npcs[assigned_id] = npc_instance

	_container.add_child(npc_instance)
	npc_instance.global_transform = global_transform

	return npc_instance

## Destroys and frees an NPC instance by its Coordinator ID.
func destroy_npc(id: int) -> bool:
	if not _tracked_npcs.has(id):
		push_warning("NPCCoordinator: Attempted to destroy un-tracked NPC ID: %d" % id)
		return false

	var npc_instance: NPC = _tracked_npcs[id]
	_tracked_npcs.erase(id)

	if is_instance_valid(npc_instance):
		npc_instance.queue_free()

	return true

## Returns a tracked NPC by ID, or null if not found.
func get_npc(id: int) -> NPC:
	return _tracked_npcs.get(id, null) as NPC

## Returns an Array of all currently tracked NPC instances.
func get_all_npcs() -> Array[NPC]:
	var result: Array[NPC] = []
	for npc in _tracked_npcs.values():
		if is_instance_valid(npc):
			result.append(npc)
	return result

## Finds nearest NPC to a given world position within max_distance in meters.
func find_nearest_npc(global_position: Vector3, max_distance: float = INF) -> NPC:
	var nearest: NPC = null
	var min_distance_sq: float = max_distance * max_distance

	for npc in _tracked_npcs.values():
		if not is_instance_valid(npc):
			continue
		var dist_sq: float = global_position.distance_squared_to(npc.global_position)
		if dist_sq < min_distance_sq:
			min_distance_sq = dist_sq
			nearest = npc

	return nearest
```

---

### 4.2 Temporary World Generator (`WorldInitializer.gd`)

**File Path:** `res://src/feudal-age/scripts/world/WorldInitializer.gd`

```gdscript
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
```

---

## 5. Execution Roadmap

1. **Rename `NpcPeasant.gd` to `NPC.gd`:** 
   Rename the script file at `src/feudal-age/scripts/characters/NpcPeasant.gd` to `src/feudal-age/scripts/characters/NPC.gd`. Update the class declaration to `class_name NPC` and replace its code with the concrete implementation in Section 2.1.
   
2. **Rename `NpcPeasant.tscn` to `NPC.tscn`:**
   Rename the scene file at `src/feudal-age/scenes/characters/NpcPeasant.tscn` to `src/feudal-age/scenes/characters/NPC.tscn`. Update internal scene references (such as script path and root node name).

3. **Update State Script casts:**
   Locate all character state scripts (under `src/feudal-age/scripts/characters/states/`) and update type casts from `NpcPeasant` to `NPC` (e.g., changing `var npc: NpcPeasant = owner as NpcPeasant` to `var npc: NPC = owner as NPC`).

4. **Coordinator Implementation:** 
   Create `src/feudal-age/scripts/world/NPCCoordinator.gd` with the implementation details from Section 4.1.

5. **Scene Tree Setup:** 
   In the active world scene:
   * Add a `Node` named `NPCCoordinator` with `NPCCoordinator.gd` attached.
   * Add a `Node3D` named `NPCContainer` as a sibling.
   * Configure `NPCCoordinator` to reference `res://src/feudal-age/scenes/characters/NPC.tscn` as the prefab and `../NPCContainer` as the container path.
   * Update references in the main `World.tscn` scene that instance the old `NpcPeasant` scene to use `NPC` instead.

6. **WorldInitializer Integration:** 
   Update `src/feudal-age/scripts/world/WorldInitializer.gd` with the code in Section 4.2 to invoke `NPCCoordinator.create_npc()`.