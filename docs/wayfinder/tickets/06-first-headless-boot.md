---
status: open
type: prototype
blocked-by: [05-audit-terrain3d-state]
---

# First headless boot of `GameCoordinator.tscn`

## Question

Get the project to the point where running `godot --path ./src/feudal-age/ --headless --quit` exits cleanly with no script errors, after first warming the global-class cache per the verification gotcha in memory:

```
godot --path ./src/feudal-age/ --headless --editor --quit
godot --path ./src/feudal-age/ --headless --quit
```

Expected console output (per `game-coordinator-implementation-plan.md`):
```
GC: Commencing system bootstrap...
GC: Bootstrap sequence executed cleanly.
GC: Processing Day Ticks: 2
...
```

The prototype work:
1. Run the warm + check sequence. Capture full output.
2. For every error / warning, decide: is it pre-existing, is it blocking, what's the smallest fix?
3. Apply fixes (likely candidates: `ManagementAPI` may be missing `get_save_snapshot()` method duck-type; `tent.tres` referenced in UI may not exist; UIDs may be stale; class_name resolution after first run).
4. Confirm `--headless --quit` exits 0.

Output target: a working build + a short findings note at `docs/wayfinder/findings/06-first-headless-boot.md` with what broke and what was fixed.

HITL considerations: this is the first time the project boots in this checkout. If the terrain3d plugin is in a bad state, the human may need to run the editor manually once to regenerate imports.