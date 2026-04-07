---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/tech/technical-spec.md
tags: [gdscript, coding-standards, conventions, best-practices]
---

# Code Conventions for Godot

## Overview

Standardized naming and organization conventions for GDScript code in Godot projects, ensuring consistency across the codebase.

## Naming Conventions

### File Names

Files use `snake_case.gd`:
- `player_controller.gd`
- `enemy_ai.gd`
- `game_manager.gd`

### Classes

Classes use `PascalCase`, matching Godot's engine type convention:
```gdscript
extends CharacterBody2D
class_name PlayerController
```

### Variables

Variables use `snake_case`:
```gdscript
var max_health: int = 100
var is_alive: bool = true
```

### Constants

Constants follow either `UPPER_SNAKE_CASE` or `camelCase` (the latter is Godot's engine convention):
```gdscript
const MAX_SPEED: float = 300.0
const gravity = 980.0
```

### Signals

Events use `past_tense_snake_case`:
```gdscript
signal health_depleted
signal item_picked_up
signal enemy_defeated
```

## Structural Guidelines

### One Script Per Node

Each node that needs custom behavior gets its own script. This keeps logic localized and testable.

### Script Size Limit

If a script exceeds approximately **300 lines**, consider splitting into component scripts. Long scripts indicate a node is doing too many things and should be decomposed.

### Composition Over Inheritance

Use Godot's node tree to compose features:
- Player = CharacterBody (physics) + Sprite (visuals) + CollisionShape (hitbox) + Script (behavior)
- This avoids deep inheritance hierarchies

## Data Management Conventions

### Resource Files (.tres)

Use Resource files for data definitions:
- Item statistics
- NPC definitions
- Dialogue tree data
- Terrain configuration

Resources act like config files but are Godot-native and can reference other resources and scenes.

### Save System

Save format options:
- **JSON** -- human-readable, easy to parse externally
- **Godot Resource** -- native format, supports complex data types

### Configuration

Game balance data and settings can use:
- Godot `ConfigFile` class (INI-like format)
- Resource files for complex configuration

See Also

- [[Godot Architecture]]
- [[Design Patterns in Game Development]]
- [[Godot Engine]]
