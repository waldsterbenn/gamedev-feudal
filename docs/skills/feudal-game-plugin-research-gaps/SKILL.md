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
| **3D Controls Toolkit** | No API docs, licensing unclear | **Integrated** in `src/feudal-age/addons/3d_controls_toolkit/` and used from `src/feudal-age/` (migrated out of the retired slice3 dir). Compatibility verified under Godot 4.7 (ADR-004). Licensing verified at integration time (check `plugin.cfg` / upstream repo). |
| **Godot version** | Research assumed "4.6" | Baseline is **Godot 4.7.x** (ADR-004, 2026-09-02; installed 4.7.2). The "4.6" rows above are historical records — treat 4.7 as the baseline going forward. |

## Still Open / Genuinely Uncertain

1. **Godot Steering AI** — Outdated (Godot 3.x), no 4.x support, 3D behaviors undocumented. **Risk: High.** Not integrated; favor built-in `NavigationAgent3D` + `CharacterBody3D` instead (already the standard per `src/AGENTS.md`).
2. **Humanizer** — v3 architecture details sparse, programmatic API undocumented, v3 unreleased. **Risk: High.** Not integrated; character work uses KayKit + Syndy assets (see `skills/kaykit-character-pack/`, `humanizer/` for status).
3. **RTS Camera & Selection** — No standardized 3D solution; selection system needs custom implementation. **Risk: Medium.** Not yet integrated; only first/third-person controls (3D Controls Toolkit) are in use.
4. **Beehave (Behavior Trees)** — Active development, but not yet integrated for NPC AI. NPCs currently use the standardized `StateMachine` + `State` node pattern from `src/AGENTS.md`. **Evaluate Beehave only if state-machine complexity outgrows its value.**

## Recommended Further Investigation (prioritized)

1. **Benchmark Terrain3D** under the project's 60 FPS / 256 MB target with realistic feudal-scene foliage counts.
2. **Document the 3D Controls Toolkit migration path** actually used (slice3 → `src/feudal-age/`) so future camera work is reproducible.
3. **Decide on Steering AI vs. NavigationAgent3D** explicitly; record the decision in an ADR (`docs/project/`).
4. ~~Re-run plugin compatibility against Godot 4.7, not 4.6, and update each skill's `compatibility:` line.~~ **Done 2026-09-02** — baseline is Godot 4.7 (ADR-004); 3D Controls Toolkit and Terrain3D verified running on 4.7.2 in-tree.

## Skill Development Priorities (current)

1. **Terrain3D** — baking navmesh from terrain, texture height-zones (in progress in `feudal-age/`).
2. **3D Controls Toolkit** — first/third-person character controller (done in slice3, **migrated to `src/feudal-age/`**).
3. **Beehave** — only if NPC AI warrants behavior trees over state machines.
4. **KayKit / Syndy assets** — character and environment art pipeline.

## Risk Assessment (revised)

- **High Risk:** Godot Steering AI (outdated), Humanizer v3 (unreleased).
- **Medium Risk:** RTS Camera (custom implementation needed), Beehave (integration undecided).
- **Low Risk:** Terrain3D (integrated, active), 3D Controls Toolkit (integrated), HTerrain (retired), Asset libraries (proven: KayKit, Syndy, AmbientCG, Polyhaven).
