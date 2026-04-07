---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/research/feudal-games-report.md
  - docs/research/feudal-system.md
tags:
  - vassal
  - loyalty
  - game-mechanics
  - ai-behavior
---

# Vassal Loyalty Systems

## Overview

The way feudal games model vassal loyalty is the single most defining design choice in the genre. This topic page documents analysis from 18 games and identifies what makes vassal loyalty mechanics compelling versus disappointing.

## Implementation Spectrum

### Deep Model: Crusader Kings III

Multi-layered approach combining:
- **Base opinion**: Personality, shared events, interactions
- **Feudal obligation**: Contract terms (levies, taxes)
- **Dread**: Authority through fear
- **Faction system**: Organized resistance
- **Vassal power**: De jure claims, demesne limits

Vassals have ambitions, relationships with other vassals, opinions of the ruler's court positions, religion, culture, and more. Rebellion generates emergent narrative stories, not punitive gameplay states.

### Simplified Model: Bannerlord

Single-axis relationship system (opinion -100 to +100). Vassals may defect if relations are poor. Makes the system readable and predictable but vassals feel like NPCs with opinion bars, not people.

## What Works

- **Named vassals** with personalities, ambitions, and relationships with each other (not just with the player)
- **Multiple axes of loyalty**: opinion, obligation satisfaction, fear/respect, shared interests
- **Rebellion as dramatic event** generating stories, not a checkbox failure state
- **Factions** that group vassals around shared grievances (taxes, religion, claims)

## What Fails

- Single metric loyalty players trivially max out by gifting
- Vassals who only exist as revenue/troop generators with no internal logic
- Rebellion without narrative framing — feels like punishment rather than drama
- No consequences for "perfect" rule (every player should face tension between competing demands)

## Key Insight

**The most engaging feudal games make vassals feel like characters with competing interests, not spreadsheets with attitude bars.** Players remember stories: "My most loyal vassal betrayed me because I promoted a rival's son to court."

## Recommended Implementation for gamedev-feudal

Based on cross-game analysis, a simplified multi-axis model using 2-3 factors is recommended:
1. **Opinion**: Personal relationship with the player/lord
2. **Obligation satisfaction**: Are the vassal's feudal demands being met?
3. **Ambition**: Each vassal has personal goals that may conflict with other vassals or the lord

## See Also

- [[feudal game mechanics]]
- [[game design takeaways]]
- [[lord fantasy psychology]]
- [[faction system]]
- [[vassalage and homage]]
