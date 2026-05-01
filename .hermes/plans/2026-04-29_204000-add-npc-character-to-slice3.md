# Plan: Add an NPC Character to Slice 3

**Goal:** Introduce a fully functional, AI-driven NPC peasant into `src/slice3-peasant-character/` using the project's existing architectural standards (component-based, State Machine, signals).

**Project:** `gamedev-feudal` — Slice `slice3-peasant-character` (`/home/ls/gamedev-feudal/src/slice3-peasant-character/`)

---

## Current Context

- `PeasantCharacter.tscn` exists but is a **pure visual** `Node3D` wrapper (FBX mesh + `AnimationPlayer`) used as a child of the Player.
- Player already demonstrates the component pattern: `CharacterBody3D` root + `StateMachine` + `HealthComponent` + `ThirdPersonControler3D`.
- The world (`World.tscn`) has a flat 50×50 floor (`StaticBody3D` + `BoxMesh`) but **no NavigationRegion3D** and **no NPC instances**.
- Reusable components are available under `scripts/components/` (`StateMachine.gd`, `State.gd`, `HealthComponent.gd`, `InteractableComponent.gd`).

---

## Proposed Approach

Create a new **NPC-specific scene** (`NpcPeasant.tscn`) with a `CharacterBody3D` root, reuse the existing `PeasantCharacter.tscn` as its visual child, and drive behavior through a dedicated AI State Machine (Idle → Patrol → Interact). Add navigation support so the NPC can pathfind on the world floor.

---

## Step-by-Step Plan

### 1. Create NPC Controller Script
**File:** `scripts/characters/NpcPeasant.gd`
- Extends `CharacterBody3D`.
- `@onready` cache references:
  - `state_machine: StateMachine`
  - `nav_agent: NavigationAgent3D`
  - `visuals: PeasantCharacter`
  - `health_component: HealthComponent`
- Expose `@export var patrol_points: Array[Vector3]` for configurable waypoints.
- Provide `move_to(target: Vector3)` helper that pushes `velocity` toward the next navigation path point.
- Connect `InteractableComponent.interacted` → state machine change to `"Interact"` state.

### 2. Create NPC State Scripts
**Directory:** `scripts/characters/states/`

| Script | Extends | Purpose |
|--------|---------|---------|
| `NpcIdleState.gd` | `State` | Wait 1–3 s, then emit `finished` → `"Patrol"`. Plays idle animation via `owner.visuals`. |
| `NpcPatrolState.gd` | `State` | Pick next waypoint from `owner.patrol_points`. Use `NavigationAgent3D` to pathfind. On arrival → `"Idle"`. Plays walk animation. |
| `NpcInteractState.gd` | `State` | Pause movement, face player, play talk/gesture animation, then return to `"Idle"` after 2 s. |

**State Machine wiring:**
- Root state machine node under `NpcPeasant` named `StateMachine`.
- Children: `Idle`, `Patrol`, `Interact`.
- `initial_state` = `Idle`.

### 3. Build NPC Scene
**File:** `scenes/characters/NpcPeasant.tscn`

**Node hierarchy:**
```
NpcPeasant (CharacterBody3D)
├── CollisionShape3D (CapsuleShape3D, height ~2.5, offset y=1.25)
├── PeasantCharacter (instance of scenes/characters/PeasantCharacter.tscn)
├── NavigationAgent3D
├── VisibleOnScreenNotifier3D (AABB ~2×2×2 centered on character)
├── HealthComponent
├── InteractableComponent (Area3D)
│   └── CollisionShape3D (BoxShape3D, roughly human-sized)
└── StateMachine
    ├── Idle
    ├── Patrol
    └── Interact
```

**Collision layers:**
- NPC root on **Layer 3** (enemies/NPCs per AGENTS.md).
- InteractableComponent Area3D on separate layer used for interaction raycasts (or match existing Player InteractorComponent mask).

### 4. Add Navigation to World
**File:** `scenes/world/World.tscn`

- Add `NavigationRegion3D` as child of `World`.
- Add a `NavigationMesh` resource to it.
- Set NavigationMesh `agent_radius` ≈ 0.5, `agent_height` ≈ 2.0.
- Include the floor (`StaticBody3D`) and building `StaticBody3D` nodes in the bake source geometry so NPC avoids walking through walls.
- Bake the navigation mesh (or let Godot auto-bake on load).
- **Alternative / fallback:** If MCP bake fails, add a manual `PlaneMesh`/`BoxShape3D` sized 48×48 as the navmesh geometry input.

### 5. Place NPC in World
**File:** `scenes/world/World.tscn`

- Instance `NpcPeasant.tscn` as a child of `World`.
- Position at e.g. `(-5, 0.5, -5)` so the player can walk up and interact.
- Configure `patrol_points` export with 3–4 local points around the NPC so it visibly moves (e.g. corners of the longhouse area).

### 6. Update EventBus (optional but recommended)
**File:** `scripts/managers/EventBus.gd`

- Add `signal npc_interacted(npc_name: String)` to keep HUD/managers decoupled.
- `NpcInteractState` can emit this via `EventBus`.

### 7. Validation

| Step | Command / Action |
|------|------------------|
| Headless integrity | `godot --path ./src/slice3-peasant-character/ --headless --quit` |
| Run project | `run_project` via Godot MCP |
| Check logs | `get_debug_output` via Godot MCP |
| Visual verification | Ensure NPC is visible, plays idle animation, patrols between points, and stops to interact when player presses **E** on it. |
| Collision check | Walk into NPC — player and NPC should collide (capsule vs capsule). |

---

## Files Likely to Change

- **New:** `scripts/characters/NpcPeasant.gd`
- **New:** `scripts/characters/states/NpcIdleState.gd`
- **New:** `scripts/characters/states/NpcPatrolState.gd`
- **New:** `scripts/characters/states/NpcInteractState.gd`
- **New:** `scenes/characters/NpcPeasant.tscn`
- **Modified:** `scenes/world/World.tscn` (add NavigationRegion3D + NPC instance)
- **Modified:** `scripts/managers/EventBus.gd` (add npc_interacted signal)

---

## Risks, Tradeoffs, and Open Questions

1. **NavigationMesh baking in `.tscn` text format** can be finicky. If Godot MCP tools struggle with `NavigationRegion3D` setup, we may need to open the editor once to bake and then save, or rely on runtime `bake_navigation_mesh()`.
2. **Animation names** — `PeasantCharacter.gd` currently assumes `"Take 001"` as the animation. NPC states must call `play_animation()` with the correct names. Verify available clips via the imported FBX or the existing debug script `scripts/debug/inspect_animations.gd`.
3. **UID churn** — When creating new `.tscn` and `.gd` files, Godot 4 will assign UIDs. Ensure `validate_godot.py` (per `godot-gdscript` skill) is run after writes to confirm references resolve.
4. **Performance** — Only one NPC for this slice, so object pooling is not required yet, but `VisibleOnScreenNotifier3D` is added as a best-practice toggle.
5. **Open question:** Should the NPC have a nameplate or dialogue UI? For this slice, a simple `EventBus.message_logged` emit is sufficient; full dialogue UI can be deferred to a future UI slice.
