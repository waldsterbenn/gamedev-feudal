# 11 — Worker control, builder auto-gather, real assets + construction feedback

**Tickets:** #70 (implemented, PR #71), #73 (bug-fix follow-up, PR #74) · **Status:** complete, playtest-verified 2026-11-01

## What was built
- **Order-anytime economy**: buildings may be ordered with insufficient resources — the order deducts what's available, records `allocated_construction_resources`, and construction **stalls** until the shortfall is gathered. Shortfall is computed **sequentially against the construction queue** (zone-level allocation vs per-building costs), matching the completion flush.
- **Builder auto-gather**: free workers temporarily woodcut while construction lacks Timber; allocation rebalances every tick; construction resumes when covered. Smoke-verified: allocated 87→123, then progress moved.
- **Player-controlled workforce (#73)**: player targets are the ONLY assignment driver — completed buildings enable job types but never auto-grab workers (`get_total_job_slots()` = `manual_job_postings` only).
- **Modifier keys** (replacing [+/−] buttons): `G`/`Shift+G` = woodcutter ±1, `F`/`Shift+F` = forager ±1. Decreases clamp at 0; increases refuse only when no free workers remain.
- **Inspection panel**: "Workers: N total" header; per-row "N assigned / N wanted"; builders row (free workers, auto); per-building progress list (`🔨 Tent — 35/50` → `✔ complete`), refreshed per day tick.
- **Real assets + construction visuals**: tent (Knights `SM_Bld_Tent_01`), forager post (Vikings `SM_Bld_Stall_Cover_01`), charcoal stack (Vikings `SM_Prop_Logs_01` ×2.2). `ConstructionVisual3D` spawns a translucent ghost at 35% scale on order, grows + solidifies with progress, opaque at completion.

## Bugs found & fixed
1. **Keyboard B hardcoded `tent.tres`** (user: "builds a tent no matter what") — now emits `blueprint_order_requested`; the panel applies its selected blueprint.
2. **Auto-grab workforce theft** (#73 user report: "Forager 2/0", decrease said "nothing to remove", construction starved) — completed buildings' `max_jobs` slots bypassed player targets. Root cause chain: auto-2-foragers consumed all workers → 0 free → no gathering. Fixed by targets-only allocation.
3. **Zone-level shortfall accounting** — a zone with 87 allocated Timber reported no shortfall even though queued buildings were unpaid; sequential per-building computation fixed it.

## Pitfalls
- `surface_material_override/0` is NOT assignable as a subscript in GDScript 2.0 — use `set_surface_override_material(0, mat)`. Also `KEY_SHIFT_LEFT/RIGHT` don't exist in Godot 4.7 (only `KEY_SHIFT`).
- POLYGON FBX are single-mesh + AnimationPlayer at raw prop scale — always probe AABB before writing scenes (tent ×0.5, logs ×2.2).
- SceneTree `_process` must return `bool` in 4.7 headless scripts.

## Open threads
- Beat 8 (deferred from #47): save/load of the slice state.
- Only Timber is auto-gathered for construction; future resources need the same shortfall routing.
