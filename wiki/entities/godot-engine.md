---
type: entity
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/tech/technical-spec.md
tags: [godot, game-engine, open-source, tool]
---

# Godot Engine

## Overview

Godot is a free, open-source game engine selected as the primary development platform for this project. The target version is 4.3 LTS or newer.

## Key Characteristics

| Attribute | Detail |
|-----------|--------|
| License | MIT (free, no royalties) |
| Editor Size | Under 100 MB |
| Primary Language | GDScript |
| Secondary Language | C++ (via GDExtension) |
| 2D Support | Pixel-perfect rendering, TileMap system |
| 3D Support | Forward+ and Compatibility renderers |
| Export | Single executable binaries per platform |
| Learning Curve | Lower than Unity (C#) or Unreal (C++) |

## Why Godot Was Chosen

1. **Cost-free and libre** -- no royalties, license fees, or ownership concerns
2. **Lightweight** -- editor runs on modest hardware, downloads as a single executable
3. **GDScript** -- Python-like language designed specifically for game development
4. **Node-based architecture** -- intuitive scene and node tree matches natural game design thinking
5. **Strong 2D support** -- pixel-perfect 2D rendering with excellent TileMap system
6. **Growing ecosystem** -- active community, frequent updates, large asset library
7. **No runtime dependency** -- exported games are standalone binaries

## Key Features

### Scene and Node System

Everything in Godot is a Node, and Scenes are saved collections of Nodes. This tree-based structure maps directly to how game objects are conceptually organized.

### Export Pipeline

Godot exports to single executable binaries for Windows, Linux, macOS, and other platforms without requiring the player to install any runtime libraries.

### Built-in Systems

- Scene management and transitions
- Input mapping system
- Animation tree and state machines
- Physics (2D and 3D)
- TileMap level design tools
- Localization with CSV/GetText
- High-level multiplayer API (ENet)

## Setup Requirements

- Download the Godot executable from godotengine.org
- No installation required -- just run the executable
- Recommended IDE: VS Code with Godot extension, or the built-in script editor
- Version control: Git with appropriate .gitignore for .import directories

## Recommended Learning Resources

1. Official "Your First 2D/3D Game" tutorial at docs.godotengine.org
2. GDQuest YouTube channel -- best free Godot tutorials
3. HeartBeast YouTube channel -- RPG and action game patterns
4. Godot Docs "Getting Started" and "Scripting" sections

## See Also

- [[Godot Architecture]]
- [[Project Structure and Organization]]
- [[AI in Game Development]]
- [[Design Patterns in Game Development]]
