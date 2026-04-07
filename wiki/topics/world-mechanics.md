---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/design/game-design.md
tags:
  - world-mechanics
  - feudal-system
  - npc-behavior
  - economy
  - day-night
---

# World Mechanics

## Overview

World mechanics define how the game world operates independently of the player. The current design document outlines four systems that need design decisions: [[feudal system]], [[NPC]] behavior, economy, and day/night cycle.

## Planned Systems

### Feudal System
The central mechanic of the game. Based on [[feudal-system-md|historical research]], this system should model:
- **[[Fief]] grants**: Land distribution and management
- **[[Vassalage]]**: Lord-vassal relationships with reciprocal obligations
- **Hierarchy**: The [[feudal hierarchy]] from [[king]] to peasant
- **Obligations**: What each party owes (military service, protection, counsel, justice)

See [[vassal loyalty systems]] for recommended loyalty model and [[recommended mechanics priority]] for implementation order.

### NPC Behavior
How [[NPC|NPCs]] act and react in the game world. Based on market research:
- [[Vassal|Vassals]] should have personalities, ambitions, and inter-relationships (not just player-facing loyalty meters)
- [[Peasant]] NPCs should reflect the three estates social structure
- Factions should form around shared interests and grievances
- See [[lord fantasy psychology]] for character-driven design principles

### Economy
The game's economic simulation. Research indicates two approaches:
- **Tactile**: Resource chains you can see and interact with (Against the Storm, Medieval Dynasty)
- **Abstract**: Universal resource (gold) with income/expense tracking ([[CK3]], [[Bannerlord]])
- **Critical**: Must remain meaningful at all game stages to avoid end-game saturation (#1 genre failure mode)
- See [[economy and resource chains]] for detailed analysis

### Day/Night Cycle
If implemented, this system affects visibility, activities, and potentially game events. Research notes that some successful medieval games use day/night cycles for atmospheric effect and gameplay variation (e.g., night-cycle siege defense in [[Kingdom Two Crowns]]).

## See Also

- [[feudal]]
- [[core gameplay loop]]
- [[vassal loyalty systems]]
- [[feudal game mechanics]]
- [[feudal system]]
- [[npc-design]]
