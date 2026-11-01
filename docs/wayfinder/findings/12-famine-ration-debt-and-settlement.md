# Findings 12 — Famine rework, settlement systems & storage-audit fix

> **Wayfinding:** Historical record for map [Wayfinder Map — Wilderness Fief Runnable Vertical Slice](https://github.com/waldsterbenn/gamedev-feudal/issues/45). Covers the famine + settlement arc shipped 2026-11-01: coherent job model (#88, PR #88), building-gated assign UI (#90, PR #90), famine v2 sticky latch (PR #92), and famine v3/v4 hardening under [#91](https://github.com/waldsterbenn/gamedev-feudal/issues/91) via **PR [#93](https://github.com/waldsterbenn/gamedev-feudal/pull/93) (merged `5c92fe5`)**. Mechanics are canonically documented in `docs/design/management-module-gdd.md` §7.

## What shipped (commit chain on PR #93)

| Version | Commit | Content |
| :-- | :-- | :-- |
| v3 | `fix/91-famine-v3-ration-debt` base | Ration-debt ledger: famine is a debt you grind out of, not a status you escape |
| v4 | `98a483f` | Deeper penalties, Camp Organization gauge + idle decay, tent auto-fill, readable status panel |
| v4.2 | `45d7c03` | Org gauge under Canopy with label, 🌾 off-the-land category row, toast background + 15 s, longer famine grind (~20 days at 8 residents) |
| v4.3 | `17cbc4d` | Hide other category rows while famine latched (only 🌾 shows) |
| v4.3b | `865eb80` | Assignment hard-gate at API layer + `T` keybind for work-through |
| fix | `5d4fa30` | Storage audit respects stacked caps — fixes the phantom Timber drain |

## Design decisions (user-locked during playtesting)

- **Sticky latch (Q18a):** famine holds until recovery conditions are met — a single hungry day doesn't flicker it on/off.
- **Ration-debt model:** "starvation is a negative modifier that subtracts food into negative; peasants living off the land slowly grind their way back into surplus over several days, so they can be freed up and re-assigned to real work." No food production = stuck until you get out (the designed loop).
- **Escape at a cost:** work-through-starvation lets you build while starving, at half construction speed while the debt deepens — progress vs. survival tradeoff.
- **Assignment lockout during famine:** all peasants are off the land; assignment buttons disable and the API refuses G/F/M keys with an explanatory toast. **Building orders stay allowed** — buildings can be queued/built through famine.
- **Org gauge spec:** 0–100, foreman +10/day, idle decay −5/day, famine −20/day, resource bonus capped at +25%.
- **Tent housing:** each completed tent pulls new peasants in to housing capacity (auto-fill), so growth is building-driven.
- **Toast timing:** plain Timer (not tick-driven) → 15 s.

## Verification lessons

- **Real-scene probes, not just domain smokes:** boot actual `GameCoordinator` + `UICoordinator`, drive ticks manually. **Determinism:** stop the GC's realtime Timer children or stray ticks interleave with manual ones (caused a day-2 contradiction: accessor read 0 while inline debug read 8). Re-fetch the zone ref each tick.
- **Cycle-aware assertions:** the game *correctly* re-latches after a famine when the camp produces zero food — a monotonic "famine never returns" probe is wrong, not the game. Assert per cycle.
- **Forager cap is 0 without a completed Forager Hut** — probes must force-complete the building (emit the real `building_completed`) before posting foragers.
- **ZoneNode stays signal-only:** a Resource must not reference the `EventBus` autoload identifier — it fails to compile in `--script` SceneTree mode (broke `smoke_loop_closure`). Route toasts through a signal → `ManagementAPI` handler.
- **The phantom Timber drain (user report):** after adding a second tent (8 peasants), Timber "drained" with nothing being built. Root cause: `_enforce_storage_caps` audited against a fixed total of 200 while per-resource caps stack with buildings (1 Lumber Camp + 1 Forager Hut = 200 exactly) — the audit silently discarded produced stock every tick (59 discard warnings in the live log), Timber first by dict order. Fix: effective capacity = `max(200, stacked caps + 40 headroom)`; fair round-robin discard; `storage_discarded` signal → toast. Headroom exists because the famine scavenge trickle deliberately bypasses per-resource caps (clamping it would deadlock recovery on a full pantry). Repro probe: 2 lumber camps + tents + 12 residents, Timber constant across idle ticks, zero discards.

## Current famine math (verified)

- Accrual: `hungry_mouths × 2` per day. Trickle: 30% of forager yield per resting resident.
- Scavenge floor (only while `famine_deficit > 0`): `resting × 2 + max(1, residents / 4)` per day.
- Exit: debt ≤ 0 **and** `food ≥ residents × 3`; pantry banks at the organic trickle rate afterward.
- Measured: 8-resident zero-production famine ≈ 20 days; 2-resident ≈ 6. Work-through (4 res): floor gross 7 < accrual 8 → debt deepens; 1 builder at half speed.

## Test status at merge

Two-stage headless gate clean; `validate_godot.py` PASSED; smokes `smoke_slice`, `smoke_loop_closure`, `smoke_contextual_hints`, `smoke_building_capacity` PASS; real-scene UI probes PASS (deleted after use, per convention).
