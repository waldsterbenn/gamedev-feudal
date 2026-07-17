---
name: feudal-game-plugin-research-gaps
description: Living tracker of open questions and resolved uncertainties for Godot plugins used in the Feudal Age project. Reflects the current integrated plugin stack.
license: N/A
compatibility: Godot 4.x (project runs on 4.7.stable), Feudal Age project
metadata:
  source: "Research report plugin-deep-research.md (superseded where noted)"
  section: "Research Gaps & Next Steps (revised)"
tags:
  - godot
  - plugin
  - research
  - feudal-age
---

# Plugin Research Gaps & Resolved Items (Feudal Age)

> **Status:** Revised. The original "Critical Information Missing" list (from `plugin-deep-research.md`) was written before any plugin was integrated. The project has since moved from planning to an active `src/feudal-age/` build on **Godot 4.7**. This skill now records what was *resolved by integration* and what *genuinely remains open*.

## Resolved by Integration (as of 2026-07-15)

| Plugin | Original Gap | Resolution |
|--------|--------------|------------|
| **Terrain3D** | Listed as "next step to test" | **Integrated and active** in `src/feudal-age/addons/terrain_3d/`. Project migrated off HTerrain. See `skills/terrain3d/SKILL.md`. |
| **HTerrain** | Advanced scripting API incomplete | **Removed as legacy.** No longer in the addon stack. Kept for reference only. |
| **3D Controls Toolkit** | No API docs, licensing unclear, 4.6 compat unknown | **Integrated** in `src/feudal-age/addons/3d_controls_toolkit/` and used in `slice3-peasant-character`. Licensing verified at integration time (check `plugin.cfg` / upstream repo). |
| **Godot 4.x version** | Research assumed "4.6" | Project actually runs on **Godot 4.7.stable**. All skill compatibility notes saying "4.6" are conservative-but-stale; treat 4.7 as the baseline. |

## Still Open / Genuinely Uncertain

1. **Godot Steering AI** — Outdated (Godot 3.x), no 4.x support, 3D behaviors undocumented. **Risk: High.** Not integrated; favor built-in `NavigationAgent3D` + `CharacterBody3D` instead (already the standard per `src/AGENTS.md`).
2. **Humanizer** — v3 architecture details sparse, programmatic API undocumented, v3 unreleased. **Risk: High.** Not integrated; character work uses KayKit + Syndy assets (see `skills/kaykit-character-pack/`, `humanizer/` for status).
3. **RTS Camera & Selection** — No standardized 3D solution; selection system needs custom implementation. **Risk: Medium.** Not yet integrated; only first/third-person controls (3D Controls Toolkit) are in use.
4. **Beehave (Behavior Trees)** — Active development, but not yet integrated for NPC AI. NPCs currently use the standardized `StateMachine` + `State` node pattern from `src/AGENTS.md`. **Evaluate Beehave only if state-machine complexity outgrows its value.**

## Recommended Further Investigation (prioritized)

1. **Benchmark Terrain3D** under the project's 60 FPS / 256 MB target with realistic feudal-scene foliage counts.
2. **Document the 3D Controls Toolkit migration path** actually used (slice3 → feudal-age) so future camera work is reproducible.
3. **Decide on Steering AI vs. NavigationAgent3D** explicitly; record the decision in an ADR (`docs/project/`).
4. **Re-run plugin compatibility against Godot 4.7**, not 4.6, and update each skill's `compatibility:` line.

## Skill Development Priorities (current)

1. **Terrain3D** — baking navmesh from terrain, texture height-zones (in progress in `feudal-age/`).
2. **3D Controls Toolkit** — first/third-person character controller (done in slice3, migrating).
3. **Beehave** — only if NPC AI warrants behavior trees over state machines.
4. **KayKit / Syndy assets** — character and environment art pipeline.

## Risk Assessment (revised)

- **High Risk:** Godot Steering AI (outdated), Humanizer v3 (unreleased).
- **Medium Risk:** RTS Camera (custom implementation needed), Beehave (integration undecided).
- **Low Risk:** Terrain3D (integrated, active), 3D Controls Toolkit (integrated), HTerrain (retired), Asset libraries (proven: KayKit, Syndy, AmbientCG, Polyhaven).
