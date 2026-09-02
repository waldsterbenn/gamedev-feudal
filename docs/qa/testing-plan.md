# QA & Testing Plan

> **Status:** Draft
> **Created:** 2026-04-05
> **Last Updated:** 2026-04-05

## Testing Strategy

### Slice Smoke & Headless Gate (authoritative, implemented 2026-09-02)

The two-stage headless gate from [Wayfinder #55/#57](https://github.com/waldsterbenn/gamedev-feudal/issues/55) is the project's verification backbone. Run from the repo root:

```bash
# Stage 1 — cache warm + integrity (must exit 0):
godot --path src/feudal-age --headless --editor --quit   # one-time per session (cold class_name parse)
godot --path src/feudal-age --headless --quit

# Stage 2 — slice smoke (must print "SMOKE: PASS", exit 0):
godot --path src/feudal-age --headless --script res://tests/smoke_slice.gd
```

The smoke boots `GameCoordinator.tscn` headless, establishes a camp at zone 1 (Ironwood Hollow), assigns the woodcutter via `ManagementAPI`, runs 3 daily ticks, and asserts real `FiefStateResource` mutation (`Timber > 0`, optional `canopy_density` drop). Repro/instrumentation scripts live beside it in `src/feudal-age/tests/` (`debug_populants.gd`, `debug_step.gd`, `debug_invest_*.gd`).

Gotchas (see map #45 Notes): in `--script` SceneTree mode, load scenes in `_process()`, never `_init()` — autoload globals are not yet script identifiers; fetch autoloads via `root.get_node("ServiceLocator")`.

### Unit Testing
- **Framework:** GUT/gdUnit4 deferred until ≥5 real units exist (decision in #55).
- **Coverage Target:** —

### Integration Testing
- **Systems to Integration Test:**

### Playtesting
- **Internal Playtest Schedule:**
- **External Playtest Schedule:**
- **Playtest Feedback Form:** (link or location)

### Build Testing

| Test Type | Frequency | Who | Notes |
|-----------|-----------|-----|-------|
| Smoke Test | Every build | Dev | Core functionality check |
| Regression | Before release | QA | All known bug fixes verified |
| Performance | Weekly | Dev | FPS, memory, load times |
| Compatibility | Monthly | QA | Different hardware/OS testing |

## Bug Tracking

- **Tracker:** (GitHub Issues / Jira / Other)
- **Priority Levels:**
  - **P0 (Critical):** Game-breaking, blocks release
  - **P1 (High):** Major feature broken, workaround exists
  - **P2 (Medium):** Minor bug, affects polish
  - **P3 (Low):** Cosmetic issues, typos, edge cases

## QA Checklist

### Core Gameplay
- [ ] Player movement feels responsive
- [ ] Combat works as designed
- [ ] Inventory system functional
- [ ] Progression saves correctly

### UI
- [ ] All buttons functional
- [ ] Text fits in containers
- [ ] Menus navigate correctly
- [ ] Settings apply correctly

### Performance
- [ ] Target FPS maintained
- [ ] No memory leaks detected
- [ ] Load times within target
- [ ] No crashes after extended play

## Known Issues

| ID | Description | Priority | Status |
|----|-------------|----------|--------|
| - | - | - | - |
