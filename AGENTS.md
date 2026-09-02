# AGENTS.md

This file provides agent-agnostic guidance for any AI coding agent (Claude, Gemini, Cursor, Codex, Aider, ...) working in this repository. It is the single source of truth for repo-level guidance; `CLAUDE.md` and `GEMINI.md` delegate to it.

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

Read `src/AGENTS.md` for the technical agent's operational instructions (MCP workflow, plugin stack, asset policy).

### Running the Project
- **Run main project**: Use the Godot MCP tool to interact with the Godot editor.
- **Run specific scene**: Add the `scene` argument to the `run_project` call.

### Debugging & Verification
- **Check Debug Output**: Use the Godot MCP tool to view console errors and stack traces:
  `get_debug_output`
- **Headless Verification**: Run a headless check to verify project integrity:
  `godot --path ./src/feudal-age/ --headless --quit`
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
    - Copy necessary assets to `src/feudal-age/assets/` for modification and version control.

## Agent skills

### Issue tracker

Issues and specs live as GitHub issues, operated via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Five canonical roles mapped to the labels `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout: one `CONTEXT.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.