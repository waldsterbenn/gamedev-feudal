---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/project/indie-game-dev-guide.md
  - docs/project/asset-naming-conventions.md
  - docs/project/design-decisions.md
tags:
  - git
  - version-control
  - project-structure
---

# Project Structure & Git

Recommended project folder structure, Git configuration, and workflow for collaborative development with Godot.

## Recommended Folder Structure

```
project/
  assets/              # All imported art and audio
    art/
      characters/
      environments/
      ui/
      vfx/
    audio/
      music/
      sfx/
      ambient/
  docs/                # Markdown documentation
    design/
    tech/
    project/
  scenes/              # .tscn files
  scripts/             # .gd or .cs files
  resources/           # .tres data files (items, stats, configs)
  shaders/
  fonts/
  builds/              # (gitignored) Exported builds
  .gitignore
  project.godot
```

## Git Configuration

### Recommended .gitignore

```
# Godot
.godot/import/
.godot/uid*
*.uid
.import/

# IDEs
.vscode/
.idea/
*.swp
*.swo

# Builds
builds/
exports/

# OS
.DS_Store
Thumbs.db
```

### Git Best Practices

- Use **Git LFS** for all audio, textures, models, and binaries over 50MB
- **Trunk-based development** or short-lived feature branches (1-3 days max)
- Small, atomic commits -- separate scene changes from script changes
- Use **pull requests with code review** even for 2-3 people
- Never manually edit .tscn/.tres files unless you understand the resource syntax

## Merge Conflict Prevention

- Split monolithic scenes into sub-scenes (UI panels, logic controllers, props, audio)
- Use signals and events instead of hard node references
- Prefer **resource-driven data** (.tres files) over hardcoded values
- Externalize content (quests, facts, stats) to JSON/CSV and import via scripts

## Asset Directory Pipeline

```
assets/
├── art/
│   ├── source/           # Native editor files -- not imported
│   ├── export/           # Exported PNGs/JPGs for Godot
│   └── reference/
└── audio/
    ├── source/           # Native project files -- not imported
    └── export/           # Final WAV/OGG for Godot
```

The `export/` folders are what Godot imports. Never edit files in `export/` -- edit in `source/` and export out.

## See Also

- [[Asset Naming Conventions]]
- [[Technical Choices]]
- [[Documentation Standards]]
- [[Design Decisions]]
