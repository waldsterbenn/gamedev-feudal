# Wayfinder Map — *Wilderness Fief* Runnable Vertical Slice

> **⚠️ SUPERSEDED (2026-09-02):** This file-based map has been migrated to the GitHub issue tracker. The canonical map is now [Wayfinder Map — Wilderness Fief Runnable Vertical Slice](https://github.com/waldsterbenn/gamedev-feudal/issues/45) (label `wayfinder:map`, waldsterbenn/gamedev-feudal). Tickets are GitHub issues #46–#55 with `wayfinder:<type>` labels and native issue dependencies for blocking; findings live as resolution comments on the closed tickets. This file and `docs/wayfinder/tickets/` + `docs/wayfinder/findings/` are kept as the historical record — do not edit them as a live map.
>
> **Tracker:** ~~local-markdown (no issue tracker is wired into this repo)~~ → GitHub issues
> **Location:** `docs/wayfinder/MAP.md` (this file) + `docs/wayfinder/tickets/*.md` (historical only)
> **Map convention:** Tickets are child markdown files of this map. Their filename is the ticket name (kebab-case). Status (`open` / `in-progress` / `closed` / `out-of-scope`) and `blocked-by` references live in each ticket's frontmatter. The frontier = open + unblocked + unclaimed tickets.

## Destination

A runnable Godot 4.6 build of *Wilderness Fief* whose `src/feudal-age/` project launches the `GameCoordinator` scene headlessly without errors, and whose player can (a) walk around a populated Terrain3D map, (b) press Tab to enter management mode, (c) click a wilderness zone and promote it to a work camp, (d) order a building, (e) watch assigned populants walk to it and forage wood over multiple game ticks, and (f) see resources move from canopy-depleted forest into the local stockpile — all while the `ManagementModule` ticks each simulated day and the `EventBus` surfaces feedback in the `ZoneInspectionMenu`. This is the smallest end-to-end vertical that proves all five pillars. Phase-2 modules (GOAP, ReservationService, SaveLoadService, Social, Warfare) are explicitly out of scope — they remain as spec-only designs that the slice lays hooks for.

## Notes

**Domain:** Godot 4.6 game development, GDScript, single-developer open-source project.
**Skills to consult per session:** `godot-project-verification` (headless integrity check), `godot-gamedev-workflow` (TDD workflow), `simplify-code` (when refactoring), `systematic-debugging` (when something fails).
**Standing preferences:**
- Architecture rules in `docs/project/architecture-overview.md` are mandatory. Do not propose "God scripts," cross-module signal calls, or hardcoded paths.
- The repo markdown under `docs/` is canonical. If you find the user has external docs (Google Docs), treat the repo copy as authoritative.
- Memory note: headless checks fail on cold class_name parse. Build global class cache with `godot --headless --editor --quit` first.
- "Done" means the game launches headless cleanly AND a human can play through the slice end-to-end without console errors.
- Out-of-scope modules (GOAP, Reservation, SaveLoad, Social, Warfare) are NOT to be implemented in this map. They are spec-only; the slice may stub their interfaces but must not build their internals.

## Decisions so far

<!-- the index: one line per closed ticket, gist of the answer, link to ticket detail -->

- [Lock the five game pillars into `game-design.md`](tickets/01-lock-game-pillars.md): Four in-scope pillars locked (Frontier colonization, Living 3D world, Headless simulation authority, Feudal-ecological economy); GOAP demoted to technique; Vassalage + Warfare elevated as out-of-scope pillars for Phase 2.

## Not yet specified

<!-- dim view of decisions still ahead. Coarser than tickets. Not blocking; just orientation. -->

- **Player experience tuning.** How fast should the in-game day tick during slice playtesting? Should Tab open instantly or animate? What's the right zoom-out view for management mode? (Ticket once a "First playable moment" prototype exists to react to.)
- **Visual fidelity of buildings.** Are `tent.tscn` etc. just colored cubes with the right collision, or do we want the KayKit medieval builder pack? Depends on what assets are licensed and running in the repo. (Ticket after the asset audit.)
- **Save/load in slice?** The TDD exists; `GameCoordinator.execute_session_save()` is a stub. Decision: include or omit? (Ticket if we discover we need it to prove "persistent fief" pillar during playtest.)
- **Player ↔ NPC interaction affordances beyond the menu.** Can the player recruit a wandering NPC into their faction during the slice, or is recruitment pre-baked in `WorldInitializer`? (Ticket after the "First loop closure" prototype.)
- **Multi-zone coordination in slice.** The slice sets up 5 zones in `WorldInitializer`. Do we need neighboring-zone effects (pull rule, commuting) for the slice to feel real, or is single-zone focus acceptable? (Ticket once single-zone loop is proven.)
- **Test harness.** How do we know a slice run "worked"? Manual play only, or scripted smoke test (e.g. headless 100 ticks, assert stockpile went up)? (Ticket before declaring slice done.)
- **Slice acceptance checklist location.** Probably `docs/qa/vertical-slice-acceptance.md` once locked.

## Out of scope

<!-- work ruled beyond the destination. Closed tickets go here with the gist + why -->

- *(none yet)*

## Frontier

<!-- The next takeable tickets. Live here, not in a separate "open tickets" listing. -->

The frontier is the union of:
1. Tickets with `status: open` AND an empty `blocked-by` list (or all-closed blockers).
2. Tickets with `status: in-progress` (claimed by a working session).

To find them: `grep -l "^status: open" docs/wayfinder/tickets/*.md` minus those whose `blocked-by` lists any non-closed ticket, plus those marked `in-progress`.

The current set of tickets created during this charting session is enumerated below.

## Tickets (full index)

- [Lock the five game pillars into `game-design.md`](tickets/01-lock-game-pillars.md) — `status: open`, `blocked-by: []`
- [Pin the slice's gameplay loop and acceptance criteria](tickets/02-pin-slice-acceptance-criteria.md) — `status: open`, `blocked-by: [01-lock-game-pillars]`
- [Pick stub-vs-omit for each non-management module](tickets/03-module-scope-for-slice.md) — `status: open`, `blocked-by: [02-pin-slice-acceptance-criteria]`
- [Audit 3D asset inventory in the repo](tickets/04-audit-3d-assets.md) — `status: open`, `blocked-by: []`
- [Audit Terrain3D state — is the world actually rendered?](tickets/05-audit-terrain3d-state.md) — `status: open`, `blocked-by: []`
- [First headless boot of `GameCoordinator.tscn`](tickets/06-first-headless-boot.md) — `status: open`, `blocked-by: [05-audit-terrain3d-state]`
- [Wire `zone_selected` → `UICoordinator.inspect_zone()`](tickets/07-wire-zone-selected-to-ui.md) — `status: open`, `blocked-by: [06-first-headless-boot]`
- [Create minimal building `.tres` blueprints](tickets/08-create-building-blueprints.md) — `status: open`, `blocked-by: [06-first-headless-boot]`
- [First slice loop closure — establish camp + watch populants work](tickets/09-first-slice-loop-closure.md) — `status: open`, `blocked-by: [07-wire-zone-selected-to-ui, 08-create-building-blueprints]`
- [Research: how to verify a slice run succeeded](tickets/10-slice-verification-strategy.md) — `status: open`, `blocked-by: []`

## Conventions for tickets in this map

- Filename = ticket name in kebab-case. Title in H1 of the body.
- Frontmatter: `status`, `type` (one of `research`, `prototype`, `grilling`, `task`), `blocked-by` (list of ticket basenames).
- Body: `## Question` (the decision or investigation) + `## Findings` (populated on close).
- Resolution = append to `## Findings`, mark `status: closed`, append a one-line gist to **Decisions so far** above.
- Out-of-scope tickets get `status: out-of-scope` and a one-line entry in **Out of scope** above, with the reason.