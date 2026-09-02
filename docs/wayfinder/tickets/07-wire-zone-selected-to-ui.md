---
status: open
type: prototype
blocked-by: [06-first-headless-boot]
---

# Wire `zone_selected` → `UICoordinator.inspect_zone()`

## Question

The UI inspection menu currently never opens because the `EventBus.ui.zone_selected` signal is emitted by `ZoneAnchor3D._on_input_event()` but `UICoordinator._ready()` has a TODO comment `# TODO(event-system): subscribe to zone select/deselect via the replacement for legacy EventBus` — the subscription is never made.

The fix (and the prototype):
1. Add the subscription: `EventBus.ui.zone_selected.connect(_on_zone_selected_external)`.
2. Implement the handler to call `inspect_zone(zone_node.node_id)`. (The signal passes a `ZoneNode`, but `inspect_zone` takes an `int` — we have to extract `node_id`.)
3. Add the matching deselect handler. The current `_on_close_pressed` in `zone_inspection_menu.gd` calls a `close_menus_fallback` that goes through the parent. We need to make sure the close button on the menu actually calls `UICoordinator.close_menus()`.

Prototype outcome: a build that, when run with the editor and a player clicks a wilderness zone anchor (after pressing Tab to enable management mode), opens the `ZoneInspectionMenu` populated with that zone's data.

This ticket may also surface other "TODO(event-system)" markers that need the same treatment — `ZoneInspectionMenu._on_day_changed`, the `message_logged` subscription, the auto-refresh on day tick. We address those here if cheap, or split a follow-up if they're substantial.

Output target: working scene + findings note at `docs/wayfinder/findings/07-wire-zone-selected-to-ui.md`.