---
status: open
type: prototype
blocked-by: [07-wire-zone-selected-to-ui, 08-create-building-blueprints]
---

# First slice loop closure — establish camp + watch populants work

## Question

This is the climax prototype. With everything wired up by tickets 06/07/08, the slice must now demonstrate the full Phase-1 management loop:

1. Boot the game.
2. Player presses Tab.
3. Player clicks zone #1 (Ironwood Hollow).
4. Player clicks "Establish Camp" → zone becomes CAMP.
5. Player clicks "Build" → tent construction starts.
6. Over 3 ticks, `construction_progress` advances and `is_completed` flips true.
7. Player opens `manual_job_postings` via the menu (this might require new UI work — TBD) — say, opens 2 forager slots.
8. Over subsequent ticks, `ZoneNode._execute_production_and_labor()` adds Berries / Mushrooms to `stockpile`.
9. Player re-opens inspection menu → stockpile counts are higher.
10. Populants are visibly parked near the zone anchor (state `AssignedWork`); they may not actually walk to forest yet because GOAP / Reservation isn't built — but their state machine enters `AssignedWork` per `ManagementAPI._notify_assignment()`.

Likely blockers this surfaces:
- **No way for the player to open a manual job** from the UI yet — may need a "Post Forager Job" button.
- **Populants stay at the spawn position**; no actual movement. Acceptable for the slice (cosmetic), but we should at least move them toward the anchor so it looks alive.
- **No `get_save_snapshot` on `ManagementAPI`** — actually we just discovered `GameCoordinator._collect_modules()` checks for it. The duck-type check might fail. (Verify during headless-boot ticket; fix here if not.)
- **No way to demote a worker or quit** — minor, can be deferred.

The prototype outcome: someone (you, the human, or a smoke test from ticket 10) can boot the game and walk through steps 1-9 and see numbers change.

Output target: working scene + findings at `docs/wayfinder/findings/09-first-slice-loop-closure.md`.

This is the largest prototype. If it splits into multiple sub-tickets during work (e.g. "build job-posting UI" emerges as its own ticket), graduate them from the **Not yet specified** section in the map.