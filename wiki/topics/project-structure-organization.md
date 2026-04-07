---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/tech/technical-spec.md
tags: [godot, project-structure, file-organization, pipeline]
---

# Project Structure and Organization

## Overview

The project follows a standardized directory layout designed for Godot game development, separating source code, scenes, resources, assets, and documentation.

## Directory Layout

```
gamedev-feudal/
├── project.godot           # Auto-generated project file
├── docs/                   # Documentation (not touched by Godot)
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
│   ├── scripts/            # .gd files
│   │   ├── managers/       # Autoload singletons
│   │   └── util/           # Shared utilities
│   ├── resources/          # .tres data definition files
│   └── shaders/            # .gdshader files
├── assets/                 # Source assets (never edited by Godot)
│   ├── art/
│   └── audio/
├── config/                 # Build and export configurations
└── build/                  # Compiled exports (.gitignored)
```

## Key Principles

### Separation of Concerns

- **src/** contains only Godot-managed files (scenes, scripts, resources)
- **assets/** contains raw source files that are imported by Godot but never modified by it
- **docs/** is completely separate from the Godot project

### Script File Organization

Scripts are matched to scenes by folder structure:
- `scripts/player/player_controller.gd` pairs with `scenes/player/player.tscn`
- `scripts/managers/` corresponds to autoload singleton scripts
- `scripts/util/` holds shared utility functionality

### Godot File Types

| Extension | Type | Purpose |
|-----------|------|---------|
| `.tscn` | Scene text | Saved node hierarchy |
| `.gd` | Script | GDScript behavior code |
| `.tres` | Resource | Data containers on disk |
| `.gdshader` | Shader | Custom rendering effects |

## Important Rules

- **Never edit `.tscn` files by hand** unless you fully understand the format. Always use the Godot editor.
- The `.import/` directory is auto-generated and should be configured for Git appropriately
- Git LFS should be considered for binary asset tracking
- Build exports should always be `.gitignored`

## See Also

- [[Godot Architecture]]
- [[Godot Engine]]
- [[Asset Pipeline]]
- [[Audio Systems Design]]
