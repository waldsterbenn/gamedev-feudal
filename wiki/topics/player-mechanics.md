---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/design/game-design.md
tags:
  - player-mechanics
  - game-design
  - controls
  - interaction
---

# Player Mechanics

## Overview

Player mechanics define how the player interacts with the game world. The current design document outlines four categories: movement, interaction, combat, and inventory. All are in placeholder status and require design decisions.

## Planned Categories

### Movement
- How the player navigates the game world
- To be defined — could be 2D top-down, 3D third-person, first-person, or abstract map view
- Input: Planned WASD (keyboard) / Left Stick (gamepad)

### Interaction
- How the player engages with NPCs, objects, systems, and UI
- Input: Planned E (keyboard) / A button (gamepad) / Left Click (mouse)

### Combat
- If applicable — TBD
- Based on market research, feudal combat could range from tactical (Battle Brothers) to strategic (CK3 levies) to action-oriented (Bannerlord)
- Research recommendation: If implementing combat, name your commanders at minimum for emotional investment. See [[medieval military system]].

### Inventory
- If applicable — TBD
- Could range from simple resource tracking to full equipment management
- Research insight: Avoid micromanagement; keep inventory meaningful but not burdensome

## Input Mapping (Template)

| Action | Keyboard | Gamepad | Mouse |
|--------|----------|---------|-------|
| Move | WASD | Left Stick | - |
| Interact | E | A | Left Click |

This is the default template mapping, to be customized per the actual design decisions.

## See Also

- [[feudal]]
- [[core gameplay loop]]
- [[world mechanics]]
- [[ui-design]]
