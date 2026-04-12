---
type: topic
created: 2026-04-12
updated: 2026-04-12
sources: ["raw/developer-instruction.md"]
tags: [godot, technical, standards, dev]
---

# Developer Instruction

Technical mandate for `gamedev-feudal` development. Governs coding standards, architectural patterns, and project hygiene.

## Core Architectural Mandates
- **Component-Based Pattern**: Decompose complex nodes into single-responsibility scripts. Forbidden: "God Scripts" > 500 lines.
- **State Machine Pattern**: Mandatory for all transient behaviors (AI, Movement).
- **Communication (EventBus)**: Use signals for decoupled interaction. NO parent-to-child queries.
- **Resource Management**: 
    - Cache dependencies with `@onready`.
    - Forbidden: `get_node()` in `_process()`.
    - Object Pooling: Mandatory for projectiles/enemies.

## 3D Best Practices
- **Base Node**: `Node3D`. Actor base: `CharacterBody3D`.
- **Optimization**: Use `VisibleOnScreenNotifier3D`, primitive collision shapes, and `CollisionLayer`/`CollisionMask` filtering.
- **Navigation**: Bake `NavigationRegion3D` and use `NavigationAgent3D` for AI pathfinding.

## Workflow & Tools
- **Godot MCP**: Primary tool for engine structural interaction (add_node, launch_editor, etc.).
- **Headless Testing**: Verify integrity with `godot --headless --quit` before commits.
- **Asset Integrity**: `/assets/original/` is read-only. Copy to `src/feudal-game/assets/` to modify.
- **VCS**: Root-level `.gitignore` only.

## See Also
- [[Technical Specification]]
