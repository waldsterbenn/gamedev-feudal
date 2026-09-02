---
status: closed
type: grilling
blocked-by: []
---

# Lock the five game pillars into `game-design.md`

## Question

The top-level game design document `docs/design/game-design.md` still has placeholder pillars ("Pillar 1 / Pillar 2 / Pillar 3"). Across the rest of the design (`management-module-gdd.md`, `goap-ai-system-gdd.md`, `reservation-service.md`, `tick-time-engine.md`, `serialization-save-system.md`, `architecture-overview.md`), five recurring design pillars emerge:

1. **Frontier colonization** — node-based progression from wilderness → work camp → village → town, driven by a localized economic loop.
2. **Living 3D world** — physical NPC agents on Terrain3D with navigation, animation, state machines; the world is not a spreadsheet.
3. **Headless simulation authority** — a stateless `ManagementModule` owns truth via `FiefStateResource`; AI and 3D actions are cosmetic, yields tick independent of animation.
4. **Feudal-ecological economy** — fertility × canopy density, settlement tiers, regional property models (Farm vs Village).
5. **Emergent GOAP labor** — action pools, dynamic costs, tool-gated prerequisites, smart-object reservations.

The decision: are these *the* five pillars for *Wilderness Fief* / *Feudal Age* (just spelled out in `game-design.md`), or do we pare down, reorder, rename, or add? The pillars will be the lens that every subsequent ticket in this map measures against — "does this feature serve at least one pillar?"

This is a grilling ticket: I want to talk with the human about whether these pillars match what they imagine the game is, what they would call them, and whether any pillar should drop for the slice.

## Findings

**Resolution (2026-08-31):**

1. **Pillars 1–4 are locked as written.** The human confirmed: "Other pillars are good."
2. **Pillar 5 (Emergent GOAP labor) is demoted from pillar → technique.** The human: "We don't see GOAP as a pillar of the game, rather it's a technique we want to use for controlling NPC behaviour, rather than a statemachine." GOAP remains in the architecture docs as a technique, not a game pillar.
3. **Two pillars elevated but placed out-of-scope for the slice map:**
   - **Vassalage and faction politics** — the royal decree framing depends on this.
   - **Warfare and raids** — armed force, defensive structures, King's tax man.
   Both are explicitly out of scope for the runnable-slice destination; they are placeholders for Phase 2.
4. **GOAP itself stays in-scope** (the slice may stub a no-op brain) but is not a pillar.

**Result:** `docs/design/game-design.md` has been rewritten with the four in-scope pillars, two out-of-scope pillars, and a "Techniques" section that explicitly names GOAP as a technique. The destination map now anchors on these four in-scope pillars.