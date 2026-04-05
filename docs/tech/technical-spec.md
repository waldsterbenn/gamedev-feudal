# Technical Specification

> **Status:** Draft
> **Created:** 2026-04-05
> **Last Updated:** 2026-04-05

## Engine & Technology

- **Engine:** Godot 4.x
- **Language:** GDScript (primary), GDExtension / C++ (if performance requires)
- **Version Control:** Git
- **Asset Pipeline:** Godot import pipeline (textures, models, audio imported via the editor)

## Why Godot

Godot was chosen for this project because:
- **Free and open source** -- no royalties, no license fees, no ownership concerns
- **Lightweight** -- the entire editor is under 100 MB, runs on modest hardware
- **GDScript** -- Python-like language designed specifically for game dev. Easier to learn than C# (Unity) or C++ (Unreal) for first-time developers
- **Node-based architecture** -- intuitive scene and node system matches how games are naturally thought about (everything is a tree of components)
- **Strong 2D support** -- pixel-perfect 2D rendering, excellent tilemap system
- **Growing ecosystem** -- active community, frequent updates, large asset library
- **Single executable export** -- games export to standalone binaries, no runtime install required by the player

## Architecture Overview

### Godot-Specific Architecture

Godot uses a **scene and node** architecture. Everything is a Node, and scenes are saved collections of nodes.

```
Game (root scene)
├── Game Manager (Node / Autoload singleton)
│   ├── State Management (State machine for menu, play, pause, game-over)
│   ├── Scene Tree Manager (scene transitions, loading screens)
│   └── Save/Load System (resource or JSON file save system)
│
├── World (Node2D / Node3D)
│   ├── TileMap / Terrain
│   ├── Objects (StaticBody, Area2D, physics bodies)
│   ├── NPCs (AnimatedSprite / CharacterBody, AI state machine)
│   └── Environment (Weather, lighting, particles)
│
├── Player (CharacterBody2D / CharacterBody3D)
│   ├── Sprite / Mesh
│   ├── Collision shape
│   ├── Animation tree
│   └── Input handling script
│
├── UI Layer (Control node)
│   ├── HUD (health, gold, minimap, objectives)
│   ├── Menus (main menu, pause, settings)
│   └── Dialog System (rich text, portrait, choice buttons)
│
└── Audio (AudioStreamPlayer nodes)
    ├── Music (looping BGM streams)
    ├── SFX (one-shot effects for combat, UI, ambient)
    └── Ambient (continuous environmental layers)
```

### Key Godot Concepts

| Concept | What it is | How we'll use it |
|---------|-----------|-----------------|
| **Scene (.tscn)** | A saved hierarchy of nodes. Everything is a scene -- the player, an enemy, a menu, a level. | Each major game element is its own scene. Compose complex objects from smaller scenes. |
| **Node** | The basic building block. Each node has one responsibility (display an image, play sound, detect collision). | Combine nodes to build features. A player = CharacterBody + Sprite + Camera + Input script. |
| **Script (.gd)** | GDScript file attached to a node. Controls behavior. | One script per node that needs custom logic. Keep scripts small and focused. |
| **Signal** | Godot's built-in event/observer system. Nodes emit signals; other nodes listen for them. | Decouple systems. Player emits `took_damage`; UI listens and updates health bar. |
| **Autoload / Singleton** | A node that loads once at game start and persists across scenes. | Game Manager, Save System, Audio Manager, Event Bus. |
| **Resource (.tres)** | Data container saved to disk. Like a config file but Godot-native. | Store item stats, NPC definitions, dialogue trees, terrain data. |
| **Group** | A way to tag nodes and get all nodes with a tag. | Group all enemies as "enemies", all interactables as "interactable". |
| **TileMap** | Grid-based level building with reusable tiles. | Build worlds efficiently without placing individual sprites. |

### Design Patterns

| Pattern | Use Case in Godot |
|---------|------------------|
| **State Machine** | Player states (idle, move, attack, stunned), AI behavior trees |
| **Observer (Signals)** | Decoupled event communication between systems |
| **Singleton (Autoload)** | Global managers that don't belong to any one scene |
| **Strategy** | Swappable behaviors (different weapon attack patterns, AI tactics) |
| **Object Pool** | Reusing frequently created/destroyed objects (arrows, particles, spawned enemies) |
| **Facade** | Simplifying complex subsystems behind a single manager node |

### Script Conventions

- File names: `snake_case.gd` (e.g., `player_controller.gd`, `enemy_ai.gd`)
- Class names: `PascalCase` (e.g., `extends CharacterBody2D`, `class_name PlayerController`)
- Variables: `snake_case` (e.g., `var max_health: int = 100`)
- Constants: `UPPER_SNAKE_CASE` or `camelCase` (Godot convention uses `camelCase` for engine constants)
- Signals: `past_tense_snake_case` (e.g., `signal health_depleted`, `signal item_picked_up`)
- One script per node. If a script exceeds ~300 lines, consider splitting into component scripts.

## Project Structure (Godot)

```
gamedev-feudal/
├── project.godot           # Godot project file (auto-generated)
├── docs/                   # Project documentation (not touched by Godot)
│   ├── design/
│   ├── tech/
│   ├── art/
│   ├── audio/
│   ├── qa/
│   └── project/
├── src/                    # Godot project root
│   ├── scenes/             # .tscn files
│   │   ├── player/
│   │   ├── enemies/
│   │   ├── ui/
│   │   ├── world/
│   │   └── menus/
│   ├── scripts/            # .gd files (matched to scenes by folder structure)
│   │   ├── player/
│   │   ├── enemies/
│   │   ├── ui/
│   │   ├── world/
│   │   ├── managers/       # Autoload singletons
│   │   └── util/           # Shared utilities
│   ├── resources/          # .tres files (data definitions)
│   │   ├── items/
│   │   ├── npcs/
│   │   ├── dialogue/
│   │   └── terrain/
│   └── shaders/            # .gdshader files
├── assets/                 # Source assets (imported by Godot, never edited by Godot)
│   ├── art/
│   │   ├── sprites/
│   │   ├── textures/
│   │   ├── tilesets/
│   │   └── ui/
│   └── audio/
│       ├── sfx/
│       ├── music/
│       └── ambient/
├── config/                 # Build and export configurations
├── build/                  # Compiled game exports (.gitignored)
└── .gitattributes          # Required for Git LFS (tracked separately if needed)
```

**Important Godot rule:** Never edit `.tscn` files by hand unless you know exactly what you're doing. Always use the Godot editor. Godot also auto-generates `.import/` directories -- these should be excluded from git if you're using Git LFS, or included if not.

## Performance Targets

| Metric | Target Platform | Target |
|--------|----------------|--------|
| Frame Rate | PC (Windows/Linux/macOS) | 60 FPS |
| Load Time | PC | < 5s (initial), < 1s (scene transitions) |
| Resolution | PC | 1920x1080 (windowed and fullscreen) |
| Max Memory | PC | < 2 GB |
| Target Godot Version | 4.3+ LTS | Current stable |

## Networking

- **Multiplayer:** TBD (Godot has built-in high-level multiplayer API using ENet)
- If multiplayer is added later: Godot's `MultiplayerAPI` supports peer-to-peer and dedicated server setups

## Data Management

- **Save File Format:** JSON or Godot `Resource` files (Godot native, human-readable)
- **Localization:** Godot's built-in Localization system with CSV/GetText translation files
- **Config Files:** Godot `ConfigFile` class (INI-like) or Resource files for game balance data

## Dependencies

| Dependency | Version | Purpose |
|-----------|---------|---------|
| Godot Engine | 4.3+ | Game engine, editor, runtime |
| Godot Git plugin (optional) | - | Source control within the editor |
| External art tools | TBD | Aseprite, Krita, Blender, etc. |
| External audio tools | TBD | Audacity, FMOD/Wwise (optional) |

## Getting Started with Godot

### 1. Download and Install
- **Godot 4.x (Standard):** https://godotengine.org/download/
- The download is a single executable -- no installation process. Just run it.
- Place the Godot executable somewhere permanent (`/opt/godot/` on Linux, `C:\Godot\` on Windows)

### 2. Create the Project
1. Open Godot → "New Project"
2. Project path: point to the `gamedev-feudal/src/` directory
3. Renderer: **Forward+** (default, best for 3D with good hardware) or **Compatibility** (for older hardware / simpler 2D)
4. Click "Create & Edit"

### 3. First Steps
- Set project settings: window size, input map, autoload singletons
- Create the first scene: a simple greybox room to test movement
- Set up version control: the `.gitignore` already covers Godot's temp files
- Open the project with `godot --path src/` or use the editor's project manager

### 4. Recommended Godot Learning Path
1. Official tutorial: "Your First 2D Game" or "Your First 3D Game" (docs.godotengine.org)
2. Godot Docs section: "Getting Started" and "Scripting"
3. GDQuest YouTube channel -- best free Godot tutorials
4. HeartBeast YouTube channel -- excellent for RPG and action game patterns
