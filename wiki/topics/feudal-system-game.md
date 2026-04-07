---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/design/world-lore.md
  - docs/research/feudal-system.md
  - docs/design/game-design.md
tags:
  - feudal-system
  - game-implementation
  - hierarchy
  - game-mechanics
---

# Feudal System (Game Implementation)

## Overview

The feudal system is the central mechanic of the Feudal game. This topic covers how the historical feudal structure is planned to be implemented in-game, informed by the [[world-lore-md|world lore bible]], [[game-design-md|game design document]], and [[feudal-system-md|historical research]].

## Hierarchy (Planned)

The game's feudal hierarchy maps to the historical structure:

1. **[[King]] / Ruler** — Supreme authority, controls all land in theory
2. **Lords / Nobles** ([[duke]], [[count]], [[baron]]) — Regional power holders
3. **[[Knight]]s / Vassals** — Military and landed class
4. **Peasantry** — Productive class (freemen, serfs, villeins)
5. **Outlaws / Rebels** — Those operating outside the feudal order

## Factions

The world lore bible includes a faction system where each faction has:
- Name and motto
- Leader (NPC)
- Territory (geographic claim)
- Relations with other factions

## Reciprocal Obligations

Core to the feudal system: every relationship involves mutual obligations.
- Vassals owe: military service, counsel, financial aids, relief
- Lords owe: protection, justice, maintenance

When obligations break, conflict arises — this is the primary source of emergent gameplay.

## Implementation References

For implementation details, see:
- [[vassal loyalty systems]] — Recommended multi-axis loyalty model
- [[recommended mechanics priority]] — Priority ordering for feudal mechanics
- [[world mechanics]] — How the feudal system interacts with other world systems
- [[game-mechanics-overview]] — Overall mechanics plan

## See Also

- [[feudalism]]
- [[feudal hierarchy]]
- [[vassalage and homage]]
- [[feudal obligations]]
- [[fief]]
- [[world-lore-bmd]]
