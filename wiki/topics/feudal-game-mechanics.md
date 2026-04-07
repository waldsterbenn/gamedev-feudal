---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/research/feudal-games-report.md
tags:
  - game-mechanics
  - feudal
  - design-analysis
  - genre-study
---

# Feudal Game Mechanics

## Overview

Analysis of core mechanical systems used across the medieval/feudal game genre, based on survey of 18 titles spanning 2015-2026. This document extracts lessons about what works and what fails in each major mechanic category.

## Core Mechanic Categories

### 1. [[Vassal Loyalty systems|Vassal Loyalty and Rebellion]]

**Best**: Crusader Kings III's multi-layered model (base opinion + feudal contracts + dread + factions + power dynamics)
**Simplest**: Bannerlord's single-axis relationship system (-100 to +100 opinion)
**Key insight**: Vassals with personalities, ambitions, and inter-relationships generate emergent single-axis loyalty systems fail because they're trivially gameable

### 2. [[Land and Territory Management]]

**Spatial approaches range from:**
- Abstract: CK3's colored political maps with modifiers
- Visual/organic: Manor Lords' burgage plots growing along roads
- Vertical construction: Going Medieval's 3D fortress building
- Frontier survival: Medieval Dynasty's wilderness clearing

**Key insight**: Players want both granular view (this farm feeds 12 people) AND grand view (my kingdom spans three provinces). The tension between detail and scope is where the fun lives.

### 3. [[Succession and Inheritance]]

**Gold standard**: CK3 makes succession the strategic game, not a penalty. Multiple succession types (partition, primogeniture, elective, gavelkind) create different experiences.
**Key insight**: Succession is only compelling when players can influence it. When it happens *to* you, it's just a chore.

### 4. [[Economy and Resource Chains]]

**Two dominant approaches:**
- Tactile/survival (Medieval Dynasty, Against the Storm): Gather, process, build, trade — satisfying but can become repetitive
- Abstract/strategic (CK3, Bannerlord): Gold as universal resource — deep but less visceral

**Primary failure mode**: End-game economy saturation is the #1 shared failure across the entire genre. Resources must matter at all stages.

### 5. [[Castle Building and Networks]]

**Three approaches:**
- Direct construction (Medieval Dynasty, Going Medieval): High ownership, time-consuming
- Abstract upgrades (CK3, Bannerlord): Fast but unsatisfying
- Middle ground (Manor Lords): Organic placement with visual growth over time

**Key insight**: Castle building needs stakes — credible threats that test defenses, and strategic castle placement with regional meaning.

### 6. [[Army Recruitment and Military]]

**Best approach**: Named commanders + faceless rank-and-file. Named soldiers create emotional investment that number-only armies cannot. Dwarf Fortress's named-soldier system is the gold standard.

## Cross-Mechanic Design Patterns

| Mechanic | Best Implementation | Common Pitfall | Player Response |
|----------|-------------------|----------------|-----------------|
| Vassal Loyalty | CK3 multi-axis | Single bar maxed by gifting | Players remember character stories |
| Land Management | Manor Lords visual growth | Abstract colored provinces | Visual > numerical growth |
| Succession | CK3 preparation gameplay | Frustrating interruption | Only good with player agency |
| Economy | Medieval Dynasty tactile chains | Abstract gold accumulation | Resource chains > single resource |
| Castle Building | First-person/3D placement | Abstract upgrades | Placement creates ownership |
| Army Management | Named commanders | Spreadsheet armies | Named characters drive attachment |

## Key Design Principle

**Narrative emergence is the primary value driver**. Systems should generate stories automatically, not just process numbers. Feudalism was messy, contradictory, and human — game design should embrace some of that messy humanity rather than pursuing perfect optimization.

## See Also

- [[feudal game design]]
- [[vassal loyalty systems]]
- [[lord fantasy psychology]]
- [[game design takeaways]]
- [[recommended mechanics priority]]
