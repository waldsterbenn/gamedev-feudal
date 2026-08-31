# Technical Design Document (TDD) — Coordinator Pattern

> **Last Updated:** 2026-08-05

## 1. Purpose & Scope

This document defines the **Coordinator** scene-tree convention used for creating, tracking, and deleting recurring entity prefabs (e.g., NPCs, items, projectiles, zone anchors). It is distinct from the root `GameCoordinator` (see `game-coordinator-module-tdd.md`); a Coordinator here is a *local, single-prefab owner* that lives in the world hierarchy.

> Often called "Managers" in game-dev parlance, Coordinators in this project are strictly responsible for **one** scene prefab type. For example, `NPCCoordinator` is the only object that may create and delete NPCs. It does not create any other prefab type.

---

## 2. Core Principle: No Domain Knowledge

A Coordinator has **no domain-specific knowledge**. It does not understand what the prefab *does*, who *uses* it, or why it exists. It only knows how to create, track, and delete Godot scene instances of one specific type.

Domain logic (e.g., management simulation, GOAP AI, combat) belongs in the **component scripts attached to the prefab itself**, not in the Coordinator. The Coordinator is agnostic to what modules those components belong to.

**The Coordinator does not decide when to create or delete prefabs on its own.** It only acts when another system explicitly calls its public API functions. Decisions about *when* and *why* to spawn something are always the responsibility of the caller.

---

## 3. Responsibilities

A Coordinator exposes a focused public API for prefab lifecycle management:

| Function | Description |
| :--- | :--- |
| `create_x(...)` | Instantiates the prefab, adds it to the container, registers it, and returns the instance. |
| `destroy_x(id)` | Removes the prefab instance from the container and frees it. |
| `get_x(id)` | Returns a tracked instance by its unique identifier. Returns `null` if not found. |
| `get_all_x()` | Returns all currently tracked instances. |
| `find_x(...)` | Optional. Locates an instance by query (e.g., nearest to a position). Added only as needed. |

The `id` used for lookup must be stable and unambiguous. It is set on the prefab by the Coordinator at creation time, not derived from domain data.

---

## 4. Scene-Tree Topology

The Coordinator node and its container are siblings placed directly under the world root. Every prefab instance the Coordinator creates lives inside the container node — never directly under the world root or any other node.

```
World (Node3D)
├── ZoneCoordinator   (Node)     ← script: zone_coordinator.gd
└── ZoneContainer     (Node3D)   ← pure folder, no script
    ├── ZoneAnchor3D             ← created by ZoneCoordinator
    └── ZoneAnchor3D
```

The container is a plain organizational node with no script or logic. Its only purpose is to keep the scene tree tidy.

---

## 5. Prefab Identity Contract

Each prefab instance must carry a stable, Coordinator-assigned `id` so it can be looked up and deleted later. This `id` is set by the Coordinator immediately after instantiation.

The identity data lives on the **root script of the prefab scene** (e.g., `ZoneAnchor3D.gd`). It must be minimal:

```gdscript
# On the prefab's root script:
var id: int = -1   # Set by the Coordinator at creation time
```

This `id` is **Coordinator-scoped** — it is only meaningful to the Coordinator. It is not a domain identifier (e.g., not the management module's `node_id`). Domain components on the same prefab manage their own identity separately.

---

## 6. What Does NOT Belong in a Coordinator

| ❌ Not allowed | ✅ Where it belongs |
| :--- | :--- |
| Deciding *when* to spawn a prefab | The system that calls `create_x()` |
| Reading or mutating simulation data | Domain component scripts on the prefab |
| Subscribing to game events or ticks | Domain component scripts on the prefab |
| Applying gameplay logic to instances | Domain component scripts on the prefab |
| Cross-module communication | `EventBus`, `ServiceLocator`, or domain systems |
