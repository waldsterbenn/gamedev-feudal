---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/project/design-decisions.md
  - docs/project/indie-game-dev-guide.md
tags:
  - technical
  - engine
  - godot
  - gdscript
---

# Technical Choices

This page documents the primary technical decisions shaping the project's architecture and toolchain.

## Game Engine: Godot 4.x

**Status:** Accepted (ADR-001)

### Why Godot 4
- Free and open source (MIT license) -- no licensing complications or royalties
- Gentle learning curve for first-time developers
- Excellent 2D support with pixel-perfect rendering
- Lightweight -- editor opens in seconds, project size stays small
- Node-tree architecture that is intuitive for programmers who understand composition
- Single-click export for Windows and Linux
- Built-in 2D tools (TileMaps, SpriteFrames, AnimationPlayer) are production-ready

### Why Not Unity
- Larger ecosystem but steeper learning curve with C#
- Licensing changes introduced uncertainty
- Heavier footprint

### Why Not Unreal
- Overkill for this project scope
- C++ presents significant learning curve
- Project sizes are large from the start

### Known Weaknesses
- Smaller ecosystem than Unity/Unreal -- fewer ready-made plugins
- Asset store is less mature -- more from-scratch development
- 3D is capable but not a strength (not relevant for 2D project)
- Debugging tools are basic compared to Unity's profiler
- Documentation has gaps -- community forums and YouTube fill them

## Scripting Language: GDScript

### GDScript vs C# Comparison

| Aspect | GDScript | C# |
|---|---|---|
| Learning curve | Minutes for any programmer | Minimal, but Godot-specific bindings to learn |
| Hot-reload | Excellent (instant) | Good (but slower) |
| Performance | Adequate for 2D casual games | Better for heavy computation |
| Community tutorials | Majority are GDScript | Growing but smaller |
| Integration | Native, first-class | Requires .NET SDK setup |

**Recommendation:** Start with GDScript for prototype and [[Development Milestones|vertical slice]]. If genuine performance limits are hit (unlikely for casual 2D), migrate performance-critical systems to C# or GDExtension (C++).

## Documentation System: Markdown

**Status:** Accepted (ADR-002)

All project documentation is written in Markdown (.md) and stored in the `docs/` directory. This provides:
- Git version control with full history
- Readability in any text editor
- No special tools required
- Branch-specific doc versions

## Project Structure

The recommended folder structure separates concerns cleanly:

```
project/
  assets/              # All imported art and audio
    art/
    audio/
  docs/                # Markdown documentation
    design/
    tech/
    project/
  scenes/              # .tscn files
  scripts/             # .gd or .cs files
  resources/           # .tres data files
  shaders/
  fonts/
  builds/              # (gitignored)
  .gitignore
  project.godot
```

## See Also

- [[Design Decisions]]
- [[Asset Naming Conventions]]
- [[Documentation Standards]]
- [[Project Structure & Git]]
- [[Godot Engine Guide]]
