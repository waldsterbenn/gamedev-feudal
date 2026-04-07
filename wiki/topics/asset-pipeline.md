---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/tech/technical-spec.md
  - docs/tech/ai-game-development-report.md
tags: [asset-pipeline, workflow, godot, import, game-development]
---

# Asset Pipeline

## Overview

The asset pipeline defines how source art, audio, and other media files flow from creation tools into the Godot game project, through import, and finally into the built game.

## Pipeline Flow

```
Source Tools (Aseprite, Krita, Blender, DAW)
    ↓
assets/ (raw source files, never edited by Godot)
    ↓
Godot Import Pipeline (auto-generated .import/ metadata)
    ↓
src/ (imported and referenced in scenes)
    ↓
Build/Export (compiled game binary)
```

## Art Asset Pipeline

### Source Files

- Art sources are stored in `assets/art/` with subdirectories for sprites, textures, tilesets, and UI
- AI-generated art should be post-processed before import
- All generated assets go through the source to export pipeline

### Godot Import

Godot automatically generates `.import/` metadata when assets are placed in the project. The import process converts source files to Godot-optimized formats.

## Audio Asset Pipeline

### Source Organization

- `assets/audio/sfx/` -- sound effects
- `assets/audio/music/` -- music tracks
- `assets/audio/ambient/` -- environmental audio

### Import Specifications

- Target: 44.1 kHz, 16-bit
- Music: OGG format for compression and looping
- Short SFX: WAV or OGG depending on length
- Godot converts to internal compressed format on import

## AI Asset Integration

AI-generated assets require additional pipeline steps:
1. **Generate** using AI tools (Stable Diffusion, Suno, etc.)
2. **Post-process** manual cleanup, color correction, format conversion
3. **Review** against [[Art Direction Overview]] or [[Audio Mood Board]]
4. **Import** into Godot via standard asset folders
5. **Reference** in scenes and scripts

## Version Control

- Binary assets should be tracked via Git LFS
- `.import/` directories should be configured for Git appropriately
- Build exports should be `.gitignored`

## See Also

- [[Project Structure and Organization]]
- [[Godot Architecture]]
- [[AI Art Generation Tools]]
- [[Sound Effects Design]]
