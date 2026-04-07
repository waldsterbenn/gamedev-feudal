---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/art/art-style-guide.md
  - docs/art/mood-board-reference.md
tags: [art-direction, visual-style, game-art, design-guidelines]
---

# Art Direction Overview

## Overview

Art direction defines the overall visual identity of the game, encompassing art style, color palette, character design, environment aesthetics, and UI presentation. A unified art direction ensures visual consistency across all game assets.

## Core Components

### Art Style Selection

The primary art style must be selected from common options:
- **Pixel Art** -- with specified resolution (16x16, 32x32, or higher)
- **Hand-drawn / Painted** -- organic, illustrative look
- **Low-Poly 3D** -- geometric, minimalist aesthetic
- **Hand-drawn 2.5D** -- 2D sprites in a 3D world
- **Cel-Shaded** -- cartoon-like shading
- **Realistic / Painterly** -- high-fidelity representation

### Color Palette Framework

Color palettes are organized by element category:

| Category | Purpose |
|----------|---------|
| **Natural Environment** | Trees, water, sky, terrain tones |
| **Castles / Fortifications** | Stone, wood, defensive structure colors |
| **UI / HUD** | Interface elements, readability focus |
| **Character Sprites** | Distinctive colors for character identification |
| **Weather / Atmosphere** | Lighting and environmental mood |

### Character Art Guidelines

Character design should address:
- **Proportions** -- realistic vs stylized body ratios
- **Level of Detail** -- how much visual complexity per character
- **Animation Style** -- frame count, smoothness, attack speed
- **Armor/Outfit Design** -- feudal era authenticity vs fantasy elements

Standard animation states include: idle, walk, run, attack, hurt, death.

### Environment Art Standards

Environment development should consider:
- **Tile/Modular Grid Size** -- consistency for level building
- **Texture Resolution** -- appropriate for target platform
- **LOD Levels** -- performance optimization for distance rendering
- **Lighting Style** -- matching the [[Visual Reference System]] mood targets

### UI Style Direction

UI should reference medieval and feudal themes while maintaining readability:
- Diegetic, medieval-authentic approaches (Kingdom Come style)
- Clean panels with heraldic motifs (Crusader Kings style)
- Gothic, parchment aesthetic (Darkest Dungeon style)
- Functional, military style (Bannerlord style)

### VFX & Effects

Visual effects should match the chosen art style:
- 2D sprites, particle systems, or shader-based effects
- Common needs: explosions, magic effects, weather systems

## Reference-Driven Development

The [[Visual Reference System]] document should be consulted before creating any art. It contains specific references, lighting studies, and mood examples to ensure all team members share the same visual target.

## See Also

- [[Visual Reference System]]
- [[Character Design Guidelines]]
- [[Environment Art Standards]]
- [[UI Art Style Guide]]
