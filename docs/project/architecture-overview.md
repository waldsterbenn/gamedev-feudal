# Architecture Overview

> **Scope:** This document describes the *high-level* architecture of the project — the macro paradigm, how the major modules relate to one another, and the cross-cutting conventions that every subsystem is expected to follow. It is intentionally system-agnostic: concrete, per-system design and technical specs live under `docs/design/` (e.g. `game-coordinator-module-tdd.md`, `ui-architecture-tdd.md`, `input-handling-architecture-tdd.md`).

## 1. The Macro Perspective

| Attribute | Details |
| :--- | :--- |
| **Project Working Title** | Feudal Age |
| **Setting** | Feudal Europe (c. 1300–1400) |
| **Perspective** | 3D Open World (Physical NPC Agents) |

* **Core Paradigm:** *Wilderness Fief* is a 3D open-world medieval management and survival game built natively for Godot 4.x utilizing a continuous physical 3D environment managed via `Terrain3D`.
* **The Management Module's Role:** The management module acts as the authoritative, headless data and economic engine of the game world. It is completely blind to 3D meshes, rendering pipelines, physics, and pathfinding. It calculates macro-level states, inventory ledgers, administrative tiers, and labor distribution, which then dictate the behavioral boundaries for all other active systems.

## 2. Cross-Module Communications & Dependencies

To ensure absolute isolation, systems remain strictly decoupled and communicate asynchronously via data layers. Global orchestration is guided by the `GameCoordinator`, which controls the lifecycle, bootstrapping order, and time ticks of the modules, while inputs are intercepted by an independent routing layer before reaching the execution blocks.

```text
                      [ Godot Engine Input Event ]
                                   │
                                   ▼
                            [ INPUT ROUTER ]
                     (Holds Keybinding Config Maps)
                                   │
         ┌──────────────────────────┴──────────────────────────┐
    (If UI is Open)                                       (If UI is Closed)
         ▼                                                     ▼
  [ UI COORDINATOR ]                                   [ GAME COORDINATOR ]
 (Toggles UI Screens)                             (System Lifecycle/Time Ticks)
         │                                                     │
         │ (UI Actions/Orders)         ┌───────────────────────┼───────────────────────┐
         ▼                             ▼                       ▼                       ▼
 [ MANAGEMENT API ]          [ MANAGEMENT MODULE ]      [ WARFARE MODULE ]      [ SOCIAL MODULE ]
(Interface Context)           (Economic Backend)         (Combat Status)      (Lineage/Affection)
         │                             │                       │                       │
         └─────────────────────────────┼───────────────────────┴───────────────────────┘
                                       ▼
                             [ DATA CONTEXT LAYER ]
                          (Exposed State & Properties)
                                       │
                                       ▼
                             [ GOAP / STATE MACHINE ]
                            (NPC Dynamic Brain Object)
                                       │
                                       ▼
                             [ 3D PHYSICAL AGENT ]
                          (CharacterBody3D on Terrain3D)
```

* **The Service Locator Pattern:** Inter-module communication is driven by a global autoloaded singleton (`ServiceLocator`). Other modules and the UI layer never hardcode references to the management systems; instead, they dynamically request an interface wrapper instance (the `ManagementAPI`) to run queries.
* **The Inter-Module Signal Ripple (Example):** When a data state changes inside the management module, it broadcasts an isolated signal. Other modules interpret this data according to their own domain logic:
  * **Management Module:** Determines a node has run out of food and emits `populants_starving`.
  * **Social Module:** Catches the signal, searches for the characters assigned to that node, and applies a heavy `-30 Happiness` modifier to their social status records.
  * **Warfare/Health Module:** Catches the signal and applies a physical health-draining status effect directly onto the 3D entity.
  * **GOAP Brain:** Evaluates the modified social and health metrics, overriding daily labor tasks to prioritize emergency actions (like stealing food or fleeing the fief).

## 3. Cross-Cutting Architecture Conventions

### 3.1 The "Call Down, Signal Up" Communication Rule
In Godot's scene hierarchy, nodes need to talk to each other. To keep modules clean, follow this strict communication rule:

* **Call Down:** A parent node can directly call functions on its children (e.g., `get_node("Sword").swing()`). This is safe because the parent "owns" the children.
* **Signal Up:** A child node should never directly call a parent. Instead, it should emit a Signal (event) that the parent listens for. This keeps the child completely modular; you can drop that child node into a totally different scene, and it won't crash looking for a parent that isn't there.

This rule is the backbone of the project's decoupling strategy. The `GameCoordinator` enforces it at the module level (see `game-coordinator-module-tdd.md`): modules never communicate horizontally — they emit blind signals that the coordinator catches and redistributes. The same principle scales down to entity-level coordinators (see `coordinator-pattern.md`).

### 3.2 The Coordinator Pattern
For spawning, tracking, and despawning recurring entity prefabs (NPCs, items, projectiles), the project uses a local **Coordinator** pattern. This is distinct from the root `GameCoordinator` — a Coordinator here is a *single-prefab owner* that lives somewhere in the world hierarchy.

* Often called "Managers" in game dev, a Coordinator is strictly responsible for **one** scene prefab type. For example, `NPCCoordinator` is the only object that may spawn and despawn NPCs, and it does not spawn any other prefab type.
* A Coordinator provides `create_x()`, `destroy_x()`, `get_x(id)`, and `find_x(...)` utilities, with more lookup helpers added as needed.
* Every prefab it instantiates lives in a sibling node called `XContainer` (a pure organizational folder).

See `coordinator-pattern.md` for the full scene-tree topology and prefab script contract.
