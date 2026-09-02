# Feudal — Design Document

> **Status:** Living document — pillars locked at the [Wilderness Fief runnable-slice wayfinder session](../wayfinder/MAP.md), 2026-08-31.
> **Created:** 2026-04-05
> **Last Updated:** 2026-08-31

## Overview

*Wilderness Fief* (working title *Feudal Age*) is a 3D open-world medieval management and survival game built natively in Godot 4.x, set in feudal Europe c. 1300–1400. The player is a **lowborn nobleman sent to the frontier by royal decree** to convert raw, unsettled wilderness into a structured, economically viable feudal estate. NPCs are physical agents on `Terrain3D` who live, consume, commute, and labor under the direction of a headless economic backend that the player can read, shape, and override via a management-mode overlay.

The four core pillars below define what makes the game *this* game, not another colony-sim or 4X. Every feature must serve at least one pillar; features that serve none are candidates for cutting.

Per-system details (settlement tiers, jobs, reservation mechanics, AI architecture, etc.) live in the `docs/design/` GDDs and `docs/technical documentation/` TDDs — this document is the **concept anchor**, not the spec.

## Game Pillars

The four **in-scope** pillars are the lens for every design decision in this map. The two **out-of-scope** pillars are explicitly outside the runnable-slice destination but define what the game is *becoming*.

### In-scope pillars

1. **Frontier colonization** — The player's progression is the transformation of raw wilderness into a structured feudal estate. The world map is a network of discrete Territory Nodes (not a tile grid); each node starts at `WILDERNESS` and the player promotes it through tiers (`CAMP` → `VILLAGE` → `TOWN`, or the Phase-2 branch `CAMP` → `FARM` → `MANOR`). The macro economic loop is **survey → camp → extract → upgrade**, and every feature that makes a node more habitable than the next belongs here. *Observable proof:* the player promotes a Wilderness node; tier changes in the data layer; new jobs / blueprints unlock in the UI.

2. **Living 3D world** — Populants are physical agents on `Terrain3D`, not spreadsheet rows. Each has a `CharacterBody3D`, `NavigationAgent3D`, `AnimationTree`, and a state machine (or, eventually, a GOAP brain — see Techniques, below). They walk, idle, animate work, react. The world reads as inhabited even when the simulation is paused. *Observable proof:* populants visibly stand on terrain; they transition through named states; a human viewer would call the world "alive".

3. **Headless simulation authority** — A stateless `ManagementModule` (the `GameModule` contract) holds the truth via `FiefStateResource`. AI actions and 3D animations are *cosmetic*: yields tick independent of whether any NPC completed a swinging-axe loop. The economic backend runs whether or not anyone is watching. This is what makes the simulation *legible*: the data layer is auditable, replayable, and survives headless boots. *Observable proof:* the master clock ticks once per in-game day and the `FiefStateResource` mutates regardless of populant animation state.

4. **Feudal-ecological economy** — Yields are emergent from a node's fertility multiplied by its current ecological state. Clear-cutting drops `canopy_density`, which suppresses mushroom yields. Settlement tier governs which buildings and jobs exist. The economy *responds to player choices* in a way that feels like land management, not inventory management. *Observable proof:* a player who clear-cuts a forest and never replants sees their mushroom yields drop in the stockpile panel; a player who reads the canopy bar before chopping sees the same drop in advance.

### Out-of-scope pillars (for this map)

These pillars *are* part of the game's eventual identity, but they sit beyond the runnable-slice destination. They are listed here so that downstream map efforts don't accidentally de-pillar them.

5. **Vassalage and faction politics** — The player owes fealty to a higher lord. Rival factions exist; reputation, tributes, royal mandates, and betrayal consequences shape what the player can and must do. The "royal decree" framing from the Overview depends on this pillar being real. *Out of scope for the runnable-slice map; placeholder for the Phase-2 effort.*

6. **Warfare and raids** — Armed force is a real threat and a real tool. Defensive structures, militia levies, the King's tax man arriving on schedule, bandit raids on outlying camps — all are part of what makes a frontier fief *dangerous*, not just *productive*. *Out of scope for the runnable-slice map; placeholder for the Phase-2 effort.*

### Techniques (not pillars)

These are *how* the game achieves the pillars, not *what* the game is. A technique can change without changing the pillars.

- **GOAP-based NPC behavior** — Goal-Oriented Action Planning with action pools (filtered by `JobPriorities` hierarchy), dynamic costs (base + physical friction + internal friction, clamped to `[1, 200]`), tool-gated prerequisites, and Smart-Object reservations. Chosen over a hand-written state machine because it makes populant behavior more legible to the management module and more robust to feature additions. *For the slice: a state machine is the placeholder; the slice may stub a no-op GOAP brain but must not build the full system.*

## Core Gameplay Loop

The slice's gameplay loop is the smallest end-to-end vertical that proves all four in-scope pillars:

1. The player spawns on a populated `Terrain3D` map and walks around (Pillar 2).
2. The player presses **Tab** to enter management mode; zone anchors light up; mouse becomes visible (Pillar 1).
3. The player clicks a `WILDERNESS` zone anchor; the `ZoneInspectionMenu` opens and shows the node's canopy, fertilities, and a button to **Establish Camp** (Pillars 1, 4).
4. The player clicks **Establish Camp**; the node's tier changes to `CAMP`; populants assigned to it transition to the assigned-work state (Pillars 1, 3).
5. The player orders a building; construction ticks complete over several in-game days (Pillars 1, 3).
6. The player opens manual jobs (forager, woodcutter); populants are matched to jobs by `JobPriorities`; over subsequent ticks, resources accumulate in the local stockpile (Pillars 3, 4).
7. The player sees the canopy bar drop as woodcutters run, and mushroom yields fall with it — the economy responds to the player's earlier choices (Pillar 4).

This loop is small, slow, and observable. Every other gameplay loop in the eventual game is an extension of this skeleton.

## Mechanics, Content, UI, Controls

Per-system mechanics are documented in the GDDs and TDDs; this document does not duplicate them. Pointers:

- **Settlement tiers, jobs, resources, the localized inventory model** → `docs/design/management-module-gdd.md` and `docs/technical documentation/management-module-tdd.md`.
- **NPC behavior, GOAP architecture, action pools, dynamic costs** → `docs/design/goap-ai-system-gdd.md` and `docs/technical documentation/goap-ai-system-tdd.md`.
- **Smart-object reservations, TTLs, evictions** → `docs/design/reservation-service.md`.
- **Time engine, day/night cycle, three-tier ticks** → `docs/design/tick-time-engine.md`.
- **Save / load via Custom Resources** → `docs/design/serialization-save-system.md`.
- **Architecture overview, service locator, event bus, coordinator pattern** → `docs/project/architecture-overview.md`, `docs/technical documentation/event-bus-tdd.md`, `docs/project/coordinator-pattern.md`.
- **UI layout, zone inspection menu** → `docs/technical documentation/ui-architecture-tdd.md`.
- **Input routing** → `docs/technical documentation/input-handling-architecture-tdd.md`.

Input mappings live in `project.godot` `[input]` (see `src/feudal-age/project.godot`); the keys are: `move_*`, `interact`, `camera_rotate`, `jump`, `toggle_management`.

## See also

- [Architecture overview](../project/architecture-overview.md)
- [Module workflow & documentation standard](../project/module-workflow-and-docs.md)
- [Runnable-slice wayfinder map](../wayfinder/MAP.md) — the destination this document anchors.

---

*The pillars in this document are the result of the first decision of the Wilderness Fief runnable-slice wayfinder map; see the **Decisions so far** section of the map for the resolution trail.*