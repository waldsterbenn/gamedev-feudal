# Project Summary & Design Alignment

## 1. High-Level Game Architecture & Module Integration

| Attribute | Details |
| :--- | :--- |
| **Project Working Title** | Feudal Age |
| **Setting** | Feudal Europe (c. 1300–1400) |
| **Perspective** | 3D Open World (Physical NPC Agents) |
### 1.1 The Macro Perspective
* **Core Paradigm:** *Wilderness Fief* is a 3D open-world medieval management and survival game built natively for Godot 4.x utilizing a continuous physical 3D environment managed via `Terrain3D`.
* **The Management Module's Role:** The management module acts as the authoritative, headless data and economic engine of the game world. It is completely blind to 3D meshes, rendering pipelines, physics, and pathfinding. It calculates macro-level states, inventory ledgers, administrative tiers, and labor distribution, which then dictate the behavioral boundaries for all other active systems.

### 1.2 Cross-Module Communications & Dependencies
To ensure absolute isolation, systems remain strictly decoupled and communicate asynchronously via data layers. Global orchestration is guided by the `GameCoordinator`, which controls the lifecycle, bootstrapping order, and time ticks of the modules, while inputs are intercepted by an independent routing layer before reaching the execution blocks.

```markdown
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



---

## 2. Character & Scene Integration

### 2.1 Character Hierarchy Definitions

* **NPC:** The comprehensive, unified 3D engine GameObject scene instance. It handles physical navigation (`NavigationAgent3D`), visual mesh animations, audio, and independent module component attachments.
* **Populant:** The economic representation of an individual inside the management ledger. A Populant possesses no spatial footprint; they exist purely as a profile tracked by the data layers.

### 2.2 The Component Bridge

The connection between the physical world and the background simulation is managed via the `ManagementPopulantComponent` attached directly inside the NPC gameobject scene.

* **The AI Translation Layer:** The standalone Goal-Oriented Action Planner (GOAP) inside the NPC scene continuously reads its own local `ManagementPopulantComponent`.
* **Orchestrating Movement:** When the control layer updates the component's data fields (such as changing its residency node or job type), the GOAP brain registers a mismatch between its current 3D position and its designated economic role. The brain then generates physical navigation tasks, commanding the NPC to march across the `Terrain3D` map to locate the appropriate physical markers matching its new data state.

---

## 3. UI & Input Separation Rules

### 3.1 The Input Map Configuration Rule

No raw hardware key strings are hardcoded into functional code. All incoming hardware signals flow natively through Godot's built-in Input Map configuration table. The `InputRouter` script intercepts unhandled input and evaluates the player's active state boundaries to route commands contextually.

* **If a menu screen is blocking gameplay:** Input maps exclusively to `UICoordinator` actions (e.g., closing a panel, cycling tabs, or selecting buttons).
* **If no screens are blocking gameplay:** Input routes directly to simulation triggers (e.g., commanding the 3D camera to pan or triggering raycasts onto `ZoneAnchor3D` nodes).

### 3.2 UI Separation & Interface Rules

The user interface resides inside an isolated, screen-pinned `CanvasLayer` branch managed by the `UICoordinator`.

* **Layout Isolation:** Panels like `ZoneInspectionMenu` or `OptionsMenu` leverage Godot’s native spatial container logic (`VBoxContainer`, `GridContainer`, `MarginContainer`) to dynamically scale to player monitors without pixel-shifting glitches.
* **Read/Write Flow:** The UI screen reads snapshot parameters from the `ManagementAPI` and hooks buttons to API execution triggers (e.g., `order_building()`). It passes parameters downwards but maintains absolutely no local data state, state computation logic, or authoritative simulation variables.

```

```