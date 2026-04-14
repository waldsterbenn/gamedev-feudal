# GEMINI.md

This file provides guidance to Gemini CLI when working with code in this repository.

## Project Overview
This repository contains the development files for `feudal-game`, a Godot-based game project focusing on feudal lore and history.

## Core Architecture & Patterns
The project follows strict architectural mandates for maintainability and performance:

- **Component-Based Pattern**: Avoid "God" scripts. Decompose complex nodes into single-responsibility components (e.g., `HealthComponent.gd`, `MovementController.gd`).
- **State Machine Pattern**: All transient entity behaviors (Player, AI) must use a standardized State Machine (Parent `StateMachine` node managing child `State` nodes).
- **EventBus Pattern**: Use a global `EventBus` singleton for decoupled communication (e.g., `EventBus.gold_changed.emit(100)`).
- **Resource Management**: Use `.tres` (Resource) files for tuning and data (NPC stats, Item data) to separate data from logic.
- **Performance**: 
    - Cache node references using `@onready`.
    - Avoid expensive operations in `_process()`.
    - Implement **Object Pooling** for frequent entities like projectiles or enemies.

## Development Commands

Read the AGENTS.md for instructions.

### Running the Project
- **Run main project**: Use the Godot MCP tool to interract with the Godot editor.
- **Run specific scene**: Add the `scene` argument to the `run_project` call.

### Debugging & Verification
- **Check Debug Output**: Use the Godot MCP tool to view console errors and stack traces:
  `get_debug_output`
- **Headless Verification**: Run a headless check to verify project integrity:
  `godot --path ./src/feudal-game/ --headless --quit`
- **Project Info**: Retrieve metadata using `get_project_info`.

## Coding Standards
- **Naming**:
    - Scenes/Nodes: `PascalCase`
    - Scripts/Variables: `snake_case`
    - Constants: `UPPER_CASE`
- **GDScript Best Practices**:
    - Always use `@onready` for persistent node references.
    - Use `CollisionLayer` and `CollisionMask` systematically.
    - Use `NavigationAgent3D` for AI pathfinding.
- **Asset Management**:
    - Keep raw 3rd-party assets in a read-only `/assets/original/` directory.
    - Copy necessary assets to `src/feudal-game/assets/` for modification and version control.
