---
type: topic
created: 2026-04-12
updated: 2026-04-12
sources: ["raw/technical-spec.md"]
tags: [godot, technical, architecture, dev]
---

# Technical Specification

Outlines the technical framework, architectural standards, and project structure for *gamedev-feudal* using Godot 4.6.

## Engine & Technology
- **Engine**: Godot 4.6 (chosen for being open-source, lightweight, and offering a robust node-based scene architecture).
- **Language**: GDScript.

## Architectural Overview
Godot features a tree-based hierarchy of Scenes (saved node collections) and Nodes (components).

### Design Patterns
- **State Machine**: For transient state management.
- **Observer (Signals)**: Decoupled communication.
- **Singleton (Autoload)**: Global management (Game Manager, Event Bus).
- **Object Pooling**: For frequent entity instantiation (arrows, particles).

## Project Structure
- `src/`: Godot project root.
- `assets/`: Immutable source assets (imported).
- `docs/`: Project documentation.

## Performance Targets
- **FPS**: 60 FPS (PC).
- **Target Memory**: < 2 GB.

## See Also
- [[Godot Nodes]]
- [[GDScript Best Practices]]
- [[Project Structure]]
