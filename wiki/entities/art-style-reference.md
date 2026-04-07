---
type: entity
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/art/art-style-guide.md
tags: [art, style-guide, reference, visual-assets]
---

# Art Style Reference

## Overview

The Art Style Reference captures the visual specifications for gamedev-feudal, including color palettes, character templates, and technical specifications for all art asset categories.

## Color Palette Structure

Colors are defined by function:

| Role | Usage |
|------|-------|
| Primary | Dominant color in the palette |
| Accent | Secondary color for emphasis |
| UI Base | Background and panel colors |
| Highlight | Interactive element emphasis |

## Character Art Template

Standard character asset specifications:

| Field | Purpose |
|-------|---------|
| Model Name | Unique identifier for the character |
| Dimensions | Pixel/physical dimensions of sprite or model |
| Triangle Count | For 3D models, polygon budget |
| Texture Resolution | Texture atlas size requirements |
| Animation States | Required animation frames: idle, walk, run, attack, hurt, death |

## Environment Art Specifications

- **Tile/Modular Grid Size** -- must align with level building conventions
- **Texture Resolution** -- standardized across all environment assets
- **Lighting Style** -- determined by [[Art Direction Overview]] choices

## UI Art Specifications

- **UI Style** -- consistent with game's medieval/feudal theme
- **Icon Size** -- standardized dimensions for all inventory and HUD icons
- **Font** -- readable, thematically appropriate typeface
- **Button States** -- normal, hover, pressed, disabled visual states

## VFX Specifications

- Effect type: 2D sprites, particle systems, or shader-based
- Common effects: explosions, magic, weather, combat feedback
- Style must match overall [[Art Style Guide]] direction

## See Also

- [[Art Direction Overview]]
- [[Visual Reference System]]
- [[Godot Architecture]]
