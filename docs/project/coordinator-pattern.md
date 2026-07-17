# Technical Design Document (TDD) — Coordinator Pattern

## 1. Purpose & Scope
This document defines the **Coordinator** scene-tree convention used for spawning, tracking, and despawning recurring entity prefabs (e.g., NPCs, items, projectiles). It is distinct from the root `GameCoordinator` (see `game-coordinator-module-tdd.md`); a Coordinator here is a *local, single-prefab owner* that lives somewhere in the world hierarchy.

> Often called "Managers" in game-dev parlance, Coordinators in this project are strictly responsible for **one** scene prefab type. For example, `NPCCoordinator` is the only object that may spawn and despawn NPCs, and it does not spawn any other prefab type.

## 2. Responsibilities
A Coordinator provides the lifecycle and lookup utilities for its prefab:

- `create_x()` — instantiate a prefab instance.
- `destroy_x()` — despawn and free a prefab instance.
- `get_x(id)` — retrieve a known instance by identifier.
- `find_x(...)` — locate an instance by query (e.g., proximity, state).

More lookup helpers are added as needed, depending on how many ways a given prefab can be identified.

## 3. Scene-Tree Topology
The Coordinator lives at the top of its local hierarchy branch. Every prefab it instantiates lives in a sibling node called `XContainer` (a pure organizational folder — no logic).

```
World (Node3D or Node)            <-- Root of your world
├── CharacterBody3D              <-- Example of another scene in the world
├── Map/Environment (Node3D)     <-- Example of another scene in the world
├── NPCcoordinators (Node)       <-- Holds your spawning/tracking script
└── XContainer (Node3D)         <-- Clean folder/container for active NPCs
    ├── NPC                     <-- Instantiated NPC
    └── NPC                     <-- Instantiated NPC
```

## 4. Prefab Script Contract
The prefab must carry a dedicated script node that the Coordinator identifies it by.

- This script must **not** belong to any other module (e.g., the management module). It is a specific prefab script node, not a shared module component.
- This node tells the Coordinator that it owns the prefab.
- The script must contain an `id` and any other data that is relevant **only** to the Coordinator (not to the broader simulation).
