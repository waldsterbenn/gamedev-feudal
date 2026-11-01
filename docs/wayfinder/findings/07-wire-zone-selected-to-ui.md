# Findings — Wire `zone_selected` to the UI (#52)

**Status: complete — verified by manual playtest (user drove the full loop on master, PR #65) and merged as the final wiring pass of the loop-closure branch.**

## What was wired

The ticket's TODO list is fully closed on `master`:

1. **`zone_selected` subscription** — `ui_coordinator.gd::_ready()` connects `EventBus.ui.zone_selected` → `_on_zone_selected(zone_node)`, which calls `inspect_zone(zone_node.node_id)` (signal carries a `ZoneNode`; handler extracts the id). Number keys 1–9 and Enter both emit this signal via `keyboard_zone_selector.gd`.
2. **Close path is decoupled** — `EventBusUI` gained `signal zone_deselected`; the menu's Close button (and Esc, handled by `ui_coordinator.gd::_unhandled_input`) goes through it. The old `close_menus_fallback()` child→parent `get_parent()` traversal is deleted — it violated the no-parent-query architecture rule. `UICoordinator` subscribes `zone_deselected` → `close_menus()`.
3. **`message_logged` subscription** — done (HUD toast label + F12 debug console; see findings 09).
4. **Day-tick auto-refresh** — `EventBus.day_ticked` → menu `_on_day_ticked()` re-renders stockpile metrics while visible.
5. **Leftover cheap TODO in this panel** — `_on_build_button_pressed`'s "No blueprints available yet." now emits a `message_logged` warn toast instead of a bare debug print.

## Deliberately NOT done here

The remaining `TODO(event-system)` markers outside the UI slice (`NpcAssignedWorkState`, `NpcInteractState`, `InteractorComponent`, `ZoneNode` internals) belong to Phase-2 hooks (GOAP re-evaluation, petitions, surfaced failures) — they are intentionally out of scope for this map.

## Player flow this enables

Tab (management mode) → number key selects a zone → inspection panel opens live → E/B/F/G act on it → Esc or Close button dismisses it. Mouse clicks on zone anchors emit the same signal path (ZoneAnchor3D → `zone_selected`).

## Prototype output

Not a separate build — the wiring landed as part of PRs #64 (blueprints, first connect) and #65 (full loop, playtest-verified). The prototype acceptance ("run with editor, open inspection on a zone") is satisfied by the same build the user playtested for #54.
