# ZoneCoordinator Documentation

> **Last Updated:** 2026-08-05

## 1. Overview & Purpose
The `ZoneCoordinator` is a dedicated, single-purpose node responsible for the creation, tracking, and deletion of `ZoneAnchor3D` gameobjects/scenes in the world. 

Following the **Coordinator Pattern**, it has absolutely no domain-specific knowledge (such as the management simulation or economic rules). It exposes a clean, programmatic API for other systems (such as world generators, scenario builders, or level triggers) to instantiate and destroy `ZoneAnchor3D` spatial representations.

---

## 2. Scene-Tree Topology
The `ZoneCoordinator` lives as a node alongside a organizational container for the spawned instances:

```
World (Node3D)
├── ZoneCoordinator (Node)       <-- Attached: zone_coordinator.gd
└── ZoneContainer (Node3D)       <-- Clean folder container for spawned ZoneAnchor3D instances
    ├── ZoneAnchor3D
    └── ZoneAnchor3D
```

---

## 3. Public API Contract
The `ZoneCoordinator` script (`zone_coordinator.gd`) exposes the following lifecycle and query methods:

### Functions
* `create_zone_anchor(id: int, global_position: Vector3) -> ZoneAnchor3D`
  Instantiates the `ZoneAnchor3D` prefab scene, assigns its Coordinator-scoped `id`, sets its position, adds it as a child of the `ZoneContainer`, registers it in the tracked dictionary, and returns the node reference.
* `destroy_zone_anchor(id: int) -> void`
  Despawns and frees the `ZoneAnchor3D` instance with the matching `id` and removes it from the tracking cache.
* `get_zone_anchor(id: int) -> ZoneAnchor3D`
  Returns the tracked node reference for the given `id`, or `null` if not found.
* `get_all_zone_anchors() -> Array[ZoneAnchor3D]`
  Returns an array of all currently active `ZoneAnchor3D` instances.

---

## 4. Prefab Script Contract (ZoneAnchor3D.gd)
To register correctly with the coordinator, `ZoneAnchor3D.gd` maintains a minimal identification field:

```gdscript
extends Area3D
class_name ZoneAnchor3D

# Coordinator-scoped identifier assigned upon instantiation
var coordinator_id: int = -1
```

All management-specific logic (e.g. `zone_data: ZoneNode` resource mapping, `EventBus` hooks) is modularly separated from the base spatial lifecycle managed by the coordinator.
