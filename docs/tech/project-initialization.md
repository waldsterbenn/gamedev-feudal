# Feudal Age — Project Initialization

**Type**: Technical Setup  
**Date**: 2026-04-30  
**Author**: Hermes Agent  
**Status**: Complete  
**Engine**: Godot 4.6.2.stable

---

## Overview

This document covers the complete initialization of the **Feudal Age** Godot 4.6 3D project located at `src/feudal-age/`. The project serves as the main game target for all vertical slice experiments and eventual migration.

---

## Architecture Decisions

| Decision | Value | Rationale |
|----------|-------|-----------|
| **Engine** | Godot 4.6.2 | Stable, enhanced 3D, native Jolt integration |
| **Renderer** | `forward_plus` | Best quality for desktop, supports VoxelGI/SDFGI |
| **Physics** | `JoltPhysics` | Superior 3D physics simulation |
| **Physics Tick** | 120/sec | Smooth character collision and movement |
| **Physics Interpolation** | `true` | Smooth rendering between physics frames |
| **Anti-Alias** | MSAA 2x + Anisotropic x4 | Terrain and domain visual clarity |
| **Input** | ActionMap (WASD + I + C) | Keyboard + controller support from day one |
| **Architecture** | Composition + State Machines + EventBus | Per AGENTS.md mandatory standards |
| **Scene Format** | `format=3` | Godot 4 mandatory |

---

## Project Structure

```
src/feudal-age/
├── project.godot
├── icon.svg                           # Feudal Age placeholder icon
├── scenes/
│   ├── main.tscn                      # Entry point scene
│   ├── player/                        # Player character scenes
│   ├── enemies/                       # Enemy/NPC scenes
│   ├── levels/                        # Level/environment scenes
│   ├── ui/                            # HUD, menus, dialogs
│   └── props/                         # Reusable prop scenes
├── scripts/
│   ├── autoloads/
│   │   ├── EventBus.gd                # Global decoupled signal system
│   │   └── GameManager.gd             # Global state + scene transitions
│   ├── core/
│   │   ├── StateMachine.gd            # Reusable state machine node
│   │   ├── StateNode.gd              # Base state class
│   │   └── HealthComponent.gd         # Reusable health component
│   └── resources/                     # .tres resource definitions
├── assets/
│   ├── models/                        # 3D assets (.glb/.fbx)
│   ├── textures/                      # PBR textures (.png/.webp)
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/
│   └── fonts/
└── addons/                            # Editor plugins (Beehave, Terrain3D, etc.)
```

**Rules enforced**:
- Single root `.gitignore` only — no nested files
- `*.import` files are committed (project metadata)
- `.godot/` cache is ignored
- No binary assets (FBX/PNG/textures) in git — local only
- Engine-agnostic naming: `feudal-age/` not `feudal-age-godot/`

---

## project.godot Configuration

### Core Settings
```ini
config_version=5
config/name="Feudal Age"
config/features=PackedStringArray("4.6")
run/main_scene="res://scenes/main.tscn"
```

### Autoloads
```ini
EventBus="*res://scripts/autoloads/EventBus.gd"
GameManager="*res://scripts/autoloads/GameManager.gd"
```

### Physics
```ini
common/physics_ticks_per_second=120
3d/physics_engine="JoltPhysics"
common/physics_interpolation=true
```

### Rendering
```ini
renderer/rendering_method="forward_plus"
anti_aliasing/quality/msaa_3d=2
textures/default_filters/anisotropic_filtering_level=4
```

### Collision Layers (Named)
```ini
[layer_names]
3d_physics/layer_1="world"       # Environment, terrain, buildings
3d_physics/layer_2="player"      # Player character
3d_physics/layer_3="enemies"     # NPCs, hostile units
3d_physics/layer_4="ui_objects"  # UI-interactable 3D objects
3d_physics/layer_5="projectiles" # Arrows, spells, thrown objects
```

### Input Map
| Action | Primary | Secondary | Controller |
|--------|---------|-----------|------------|
| `move_left` | A | Left Arrow | Left stick X- |
| `move_right` | D | Right Arrow | Left stick X+ |
| `move_forward` | W | Up Arrow | Left stick Y- |
| `move_back` | S | Down Arrow | Left stick Y+ |
| `interact` | E | — | Face button 0 |
| `camera_rotate` | R/C | — | D-pad 9 |

All inputs have `deadzone: 0.2` for analog precision.

---

## Core Systems

### EventBus (Autoload)

Decoupled signal communication system. All game systems communicate through events, not direct references.

**Signals**:
| Signal | Parameters | Purpose |
|--------|-----------|---------|
| `domain_changed` | `new_domain_name: String` | Player switches feudal domain |
| `vassal_loyalty_changed` | `vassal_name, new_loyalty` | Vassal loyalty updates |
| `gold_changed` | `new_amount: int` | Treasury changes |
| `prestige_changed` | `new_prestige: int` | Reputation changes |
| `season_changed` | `season_index: int` | Season transitions (0-3) |
| `peasant_dispute_started` | `vassal_a, vassal_b` | Conflict events |
| `game_paused` | — | Game enters pause |
| `game_resumed` | — | Game resumes |
| `level_loaded` | `level_name: String` | New level/scene loaded |
| `player_died` | — | Player character death |

**Usage**:
```gdscript
EventBus.gold_changed.emit(new_amount)
# Listener: EventBus.gold_changed.connect(_update_gold_ui)
```

**Note**: Autoload scripts must NOT use `class_name`. Godot treats autoload names as singleton references, and `class_name` creates a conflict: `Class "X" hides an autoload singleton`.

### GameManager (Autoload)

Global state management and scene transitions.

**State**:
```gdscript
enum GameState { MAIN_MENU, PLAYING, PAUSED, GAME_OVER, DOMAIN_SCREEN }

var current_state: GameState
var current_domain: String
var gold: int
var prestige: int
var current_season: int
```

**Methods**:
| Method | Parameters | Purpose |
|--------|-----------|---------|
| `change_scene` | `scene_path: String` | Transition to new scene |
| `update_gold` | `delta: int` | Modify gold, auto-emits signal |
| `set_pause_state` | `paused: bool` | Toggle pause, emits signal |

### StateMachine (Core Node)

Reusable state machine node for entity behavior. Attach as child to any node, add state children.

**Usage pattern**:
```
Player (CharacterBody3D)
└── StateMachine (StateMachine node)
    ├── IdleState (StateNode)
    ├── WalkState (StateNode)
    └── AttackState (StateNode)
```

```gdscript
# Access from within a StateNode:
# owner = the entity being controlled (CharacterBody3D)
# parent_sm = reference to StateMachine for transitions
func update(_delta: float) -> void:
    if Input.is_action_just_pressed("jump"):
        parent_sm.transition_to("jump")
```

**Key behavior**:
- On `_ready()`: auto-discovers child StateNodes, disables their processing
- On `transition_to()`: calls `exit()` on current, `enter(msg)` on next
- Inactive states get `PROCESS_MODE_DISABLED` — zero CPU overhead

### StateNode (Base State)

Base class for all state implementations. Override `enter()`, `exit()`, `update()`.

| Method | Purpose |
|--------|---------|
| `enter(msg: Dictionary)` | Initialize state with optional data |
| `exit()` | Clean up before state switch |
| `update(_delta: float)` | Per-frame logic when active |

### HealthComponent (Core Node)

Reusable health component for any entity.

**Signals**:
- `died` — entity has zero health
- `health_changed(current: int, max: int)` — health modified

**Methods**:
- `take_damage(amount: int)` — reduce health, emit signals
- `heal(amount: int)` — restore health up to max

**Usage**: Attach as child node to any entity requiring health.

---

## Main Scene Architecture

`scenes/main.tscn` is the game entry point with the following node hierarchy:

| Node | Type | Purpose |
|------|------|---------|
| `Main` | `Node3D` | Root — does not participate in physics |
| `DirectionalLight3D` | `DirectionalLight3D` | Sun lighting with shadows enabled |
| `WorldEnvironment` | `WorldEnvironment` | Sky, fog, post-processing |
| `Camera` | `Camera3D` | Base camera (fov: 60, far: 1000) |
| `Domain` | `Node3D` | Container for feudal domain content |
| `FeudalMap` | `SubViewport` | Container for kingdom map view (CK3/Manor Lords style) |
| `UI` | `CanvasLayer` | HUD, menus, dialogs container |

---

## Validation Process

All implementation was validated through three layers:

1. **Godot headless check**: `godot --path ./src/feudal-age --headless --quit` → exit code 0
2. **Script validation**: `validate_godot.py` on every `.gd` and `.tscn` file → all passed
3. **Plan verification**: 91/91 automated checks covering every plan item → complete

**Common pitfall encountered**: Autoload scripts using `class_name` matching their autoload name cause a fatal parse error (`Class "X" hides an autoload singleton`). All autoload scripts use `extends Node` without `class_name`.

---

## Next Steps

The project is initialized and ready for vertical slice development. Recommended next slice:

1. **`slice4-core-vassal-system`** — Implement vassal loyalty system with named NPCs, opinion/fear/obligation axes, and faction grouping
2. **`slice5-terrain-generation`** — HTerrain integration with heightmap noise, texture painting, navigation baking
3. **`slice6-feudal-map-view`** — SubViewport-based kingdom map with province rendering

Each slice is developed in `src/slice_N/`, validated independently, then migrated to `src/feudal-age/` when complete.

---

## References

- **AGENTS.md**: `src/AGENTS.md` — Architectural standards and operational workflow
- **Godot 3D Architecture Research**: `docs/research/godot-3d-architecture-research.md`
- **Godot 4.6 Best Practices**: `docs/research/godot-4.6-best-practices-comprehensive-report.md`
- **Feudal Games Report**: `docs/research/feudal-games-report.md`
- **Feudal System Research**: `docs/research/feudal-system.md`
