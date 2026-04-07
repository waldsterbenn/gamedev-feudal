---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/tech/technical-spec.md
tags: [godot, architecture, game-engine, scene-graph, nodes]
---

# Godot Architecture

## Overview

The Godot engine uses a **scene and node** architecture where everything is represented as a Node, and scenes are saved collections of nodes organized in a tree structure. This node-based approach matches how games are naturally conceptualized -- as a tree of components.

## Core Concepts

### Nodes

A **Node** is the fundamental building block in Godot. Each node has one specific responsibility, such as:
- Displaying an image ([[Sprite]])
- Playing sound ([[AudioStreamPlayer]])
- Detecting collisions ([[CollisionShape]])
- Running game logic ([[Script]])

Nodes are combined to build complex game objects. For example, a player entity might combine a CharacterBody node, Sprite node, Camera node, and a custom input handling script.

### Scenes

A **Scene** (file extension `.tscn`) is a saved hierarchy of nodes. In Godot, everything is a scene -- the player, an enemy, a menu, an entire level. Scenes are composed from smaller scenes, enabling modular game development.

### Autoload Singletons

An **Autoload** is a node that loads once at game start and persists across all scenes. Common autoload singletons include:
- **Game Manager** -- handles state management, scene transitions, save/load
- **Event Bus** -- decoupled communication between systems
- **Audio Manager** -- centralized audio control

## Scene Tree Structure

A typical game structure in Godot looks like:

```
Game (root scene)
├── Game Manager (Autoload singleton)
│   ├── State Management
│   ├── Scene Tree Manager
│   └── Save/Load System
├── World (Node2D/Node3D)
│   ├── TileMap/Terrain
│   ├── Objects (StaticBody, Area2D)
│   ├── NPCs (AnimatedSprite, AI state machine)
│   └── Environment
├── Player (CharacterBody2D/3D)
│   ├── Sprite/Mesh
│   ├── Collision shape
│   ├── Animation tree
│   └── Input handling
├── UI Layer (Control node)
│   ├── HUD
│   ├── Menus
│   └── Dialog System
└── Audio (AudioStreamPlayer nodes)
```

## Godot-Specific Features

| Feature | Description | Use Case |
|---------|-------------|----------|
| **Signal** | Built-in event/observer system | Decouple systems -- one node emits, others listen |
| **Resource (.tres)** | Data container saved to disk | Store item stats, NPC definitions, dialogue trees |
| **Group** | Tag nodes for batch operations | Group all enemies or interactables |
| **TileMap** | Grid-based level building | Build worlds from reusable tiles |
| **Script (.gd)** | GDScript attached to nodes | One script per node with custom logic |

## Design Patterns Used

Godot's architecture naturally supports several design patterns:
- **State Machine** -- Player states (idle, move, attack, stunned), AI behaviors
- **Observer Pattern** -- Signals for decoupled event communication
- **Singleton** -- Autoload singletons for global managers
- **Strategy Pattern** -- Swappable behaviors for weapons and AI tactics
- **Object Pool** -- Reuse frequently created/destroyed objects
- **Facade** -- Simplify complex subsystems behind manager nodes

## Project Conventions

- File names use `snake_case.gd`
- Class names use `PascalCase`
- Signals use `past_tense_snake_case`
- Scripts should stay under ~300 lines, splitting into components when larger

## See Also

- [[Godot Engine]]
- [[Project Structure and Organization]]
- [[Design Patterns in Game Development]]
- [[Audio Systems Design]]
- [[AI in Game Development]]
