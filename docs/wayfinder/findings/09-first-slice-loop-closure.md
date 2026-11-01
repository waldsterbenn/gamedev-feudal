# Findings — First Slice Loop Closure (#54)

**Status: complete — merged PR #65 (dca5abe), playtest-verified, #54 closed.** The full Phase-1 management loop (ticket #54 steps 1–9) is wired player-facing; the data layer was already complete.

## What was added (branch `feature/loop-closure`)

### Day-tick signal (was missing)
- `EventBus.gd`: new `signal day_ticked(day: int)`.
- `game_coordinator.gd`: emits after every module has processed the tick.
- `zone_inspection_menu.gd`: connects and live-refreshes all display metrics while visible — stockpile counts now update on-screen every in-game day (ticket step 9). Replaced the dead `_on_day_changed` stub.

### Manual job postings (ticket blocker #1: "no way to post a job from UI")
- `ManagementAPI.post_manual_job(node_id, job_type, slots=2) -> bool` — appends to `ZoneNode.manual_job_postings`, refused at WILDERNESS tier (`operation_failed` signal).
- `ZoneInspectionMenu.tscn`: new `🌿 Post 2 Forager Jobs` button (visible when zone is CAMP tier).
- Keyboard `F` posts 2 forager slots on the selected zone.

### Keyboard access for the whole loop (user has no mouse)
- `E` = Establish Camp on selected zone (wilderness only — API enforces tier check).
- `F` = Post 2 Forager Jobs on selected zone.
- `B` = order tent (from #53).
- HUD label: `Tab=Mode  1-9=Zone  Enter=Inspect  E=Camp  B=Build  F=Forager`.
- All special-action interactions log via `DEBUG:` prints (per project preference).

### Smoke test for the loop
`tests/smoke_loop_closure.gd` — walks the full loop deterministically:
1. Boot GameCoordinator headless, wait for populant registration
2. `establish_camp(1)` → asserts CAMP tier
3. `order_building(1, tent.tres)` → asserts Timber deducted (30 → 5)
4. `post_manual_job(1, "forager", 2)` → asserts accepted
5. Recruit + assign a forager populant if one is registered
6. 4 deterministic ticks → asserts tent `is_completed` (50/50 work) **and** forager production grew the stockpile

Result: `SMOKE: PASS` (tent progress=50.0/50 completed=true, Mushrooms +4 over 4 ticks). Both smoke tests pass; `--headless --quit` gate exit 0.

## Ticket blockers disposition
- **"Post Forager Job" button** — implemented (button + `F` key + API).
- **Populants stay at spawn** — accepted for the slice per the ticket (cosmetic). They already spawn at anchor offsets; `assign_to_work()` switches the NPC state machine to `AssignedWork` (`ManagementAPI._notify_assignment`). Real walking to forest awaits GOAP/Reservation.
- **`get_save_snapshot` duck-type check** — `management_module.gd` already implements it (returns `{}`); GC boot passes.
- **No way to demote/quit** — deferred (ticket says minor).

## Player flow to verify manually
1. Boot game → `Tab` → `1` → `Enter` (inspection opens, zone is Wilderness)
2. `E` → tier label changes to "Camp", Establish button swaps to Build/Forager buttons
3. `B` → tent ordered (Timber 30 → 5)
4. Watch the panel for a few days: tent completes, timber regrows via woodcutter
5. `F` → "Post Forager Job result: true"; over days Berries/Mushrooms counts move
6. `B` again after stockpile regrows → second tent order succeeds

## Next
- Unblocks ticket #10-style verification and later: GOAP movement, ReservationService, job demotion UI, save snapshot data.
