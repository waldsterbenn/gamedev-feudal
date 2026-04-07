---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/design/level-design.md
tags:
  - level-design
  - progression
  - world-structure
  - gating
---

# Level Progression Template

## Overview

The level progression system defines how game areas connect and the sequence in which players experience them. This document tracks the template and structure for level progression in the Feudal game.

## Progression Structure

Progression is tracked via a progression table:

| Order | Area | Unlocked By | Locks (What It Unlocks) |
|-------|------|-------------|------------------------|
| 1 | Starting Area | N/A | - |

This template tracks:
- **Order**: The intended sequence of area discovery
- **Area**: Name of the game area
- **Unlocked By**: What conditions grant access (quest completion, permission, resource threshold, etc.)
- **Locks**: What new areas become accessible after completing this area

## Feudal Progression Model

For a feudal-themed game, natural progression models include:

### Territorial Expansion
- Start: Single manor/domain
- Progress outward: Control adjacent territories through grants, conquest, or inheritance
- End game: Regional or kingdom-level control

### Social Ascent
- Start: Minor lord/baron
- Rise: Gaining favor, land, and titles
- End game: King or supreme ruler

### Generational
- Start: First generation of a dynasty
- Progress: Through succession events ([[succession and inheritance]])
- Each generation unlocks new areas and larger domains

## Area Template

Each area entry should include:
- **Layout description**: Physical space, key landmarks, player flow
- **Points of interest**: Named locations within the area
- **Enemy encounters**: Threats and their placement
- **Puzzles/challenges**: Environmental or social obstacles
- **Secrets**: Optional content for dedicated players
- **Visual mood**: Atmospheric design direction

## See Also

- [[level-design-md]]
- [[level-design-principles]]
- [[succession and inheritance]]
- [[world-lore-bible]]
- [[core gameplay loop]]
