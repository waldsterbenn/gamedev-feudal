# Findings: How to verify a slice run succeeded

**Ticket:** `docs/wayfinder/tickets/10-slice-verification-strategy.md`
**Status:** recommendation — read top section first, then "Chosen approach" for the concrete plan.
**Repo state at time of writing:** Godot 4.6 project at `src/feudal-age/`; no `tests/` directory; no `.github/workflows/`; one existing `src/feudal-age/test_gen.gd` already uses the `extends SceneTree` + `--script` headless pattern; `WorldInitializer._ready()` creates 5 known zone nodes and assigns 7 known populants; `GameCoordinator` runs a 3-second master timer tick that calls `ManagementModule.process_tick(game_context)`; `FiefStateResource` is the `Resource` holding `world_nodes`; `world_nodes[1]` is "Ironwood Hollow" (fert. Timber 0.8, canopy 1.0) with a woodcutter + an unskilled worker.

---

## Top recommendation (one paragraph)

For this repo's size and team (single developer, first-time), **build one custom GDScript smoke test that boots the actual `GameCoordinator` scene headless, fast-forwards N ticks deterministically, asserts that a domain-side state mutation actually happened (e.g. `FiefStateResource.world_nodes[1].stockpile["Timber"] > 0` after T ticks where node 1 has been turned into a CAMP), and exits with a real exit code via `SceneTree.quit(0|1)`**. Pair it with the existing `--headless --quit` integrity check as a fast gate before the smoke runs. **Skip** Godot's built-in `--test` mode (it's for the engine's own C++/GDScript-interpreter tests, not user-game logic — confirmed in the official docs). **Defer** full GUT/gdUnit4 adoption until the project has ≥5 test-worthy units; the `--script` smoke test is simpler, requires no addons, costs zero runtime overhead, and exercises the real production code path including the autoload-bound bootstrap that has bitten this project before (per the `godot-project-verification` skill §7 "silent-skip failures").

The ticket's own example — `FiefStateResource.world_nodes[1].stockpile["Timber"] > 0` after 30 ticks — is the right shape; this doc makes it concrete (where the file lives, what it instantiates, what it asserts, how it exits, how CI calls it).

---

## Options considered

### Option A — Manual play only

A human launches the project, walks a populant to a node, establishes a camp, waits 30 in-game days, eyeballs the stockpile. Simple, no infrastructure, but: not reproducible, not CI-runnable, and the exact failure mode this project has hit repeatedly (silent-skip — see `godot-project-verification` §7) would only be caught by a human who happened to know what to look for. Rejected as the *only* gate, but useful as a final human check after automation passes.

### Option B — Custom GDScript headless smoke (extends SceneTree)

The existing `src/feudal-age/test_gen.gd` already proves this works in this codebase: `extends SceneTree`, work in `_init()`, load a scene, do work, call `quit()` or `quit(1)`. The official docs confirm: "The script must inherit from `SceneTree` or `MainLoop`", "must be a resource path relative to the project (myscript.gd will be interpreted as `res://my_script.gd`)", and `SceneTree.quit(exit_code: int = 0)` "Quits the application at the end of the current iteration, with the given `exit_code`. By convention, an exit code of `0` indicates success, whereas any other exit code indicates an error." That gives us real CI exit codes for free — no shell wrapper needed. The smoke can `instantiate()` the real `GameCoordinator.tscn` (which gives us the autoloads + `WorldInitializer` + `ManagementModule` + the master clock), then either let the real 3-second `Timer` fire or call `_on_simulation_tick_elapsed()` manually N times for determinism. **This is the recommended approach.**

### Option C — Visual screenshot diff

Boot the slice, render one or more frames to PNG, byte-compare against a checked-in baseline. Catches renderer / terrain / material regressions that pure-logic smoke can't see (and this project uses Terrain3D + Glow + Sky — those are real risk surfaces). Drawbacks: baseline maintenance burden (every intentional UI/lighting tweak forces a re-bless of the baseline), pixel diffs are noisy on float-renderer output, and `--headless` doesn't always render correctly without a `--display-driver` workaround. **Not the primary gate**, but worth keeping on the roadmap as a secondary check once the slice has stable visuals. For the current "did the simulation actually mutate state" question, screenshot diff answers the wrong question.

### Option D — Godot's built-in `--test` mode

The ticket lists this as a candidate. **It does not apply to user-game logic in Godot 4.6.** The official docs are explicit: "Godot Engine allows to write unit tests directly in C++. The engine integrates the [doctest](https://github.com/doctest/doctest) unit testing framework... tests reside in a dedicated `tests/` directory instead, which is located at the root of the engine source code." Running `godot --test` from a *project* (not from the engine source build) either no-ops or runs engine-internal C++ tests against a project that has no connection to them. The `--test-suite="*GDScript*"` filter is for the GDScript *interpreter*'s own tests, not project scripts. **There is no native `class Foo extends TestCase` GDScript runner in Godot 4.6.** Rejected.

### Option E — Community frameworks (GUT, gdUnit4)

Both are real, mature, GDScript-native. GUT (`github.com/bitwes/Gut`) and gdUnit4 are the two popular choices. Both work via `--script` from the command line and emit standard exit codes. They are genuinely the right answer once the project has 5+ unit-test-shaped problems. For a single "did the slice run" check, the per-test ergonomics (`assert_eq`, `before_each`, parameterized cases) don't earn their keep: we'd write one file that does one thing, and the existing `extends SceneTree` + `quit(0|1)` pattern gets us the same CI exit code in 30 fewer lines and zero new dependencies in `addons/`. **Recommend deferring adoption** (file a ticket to introduce gdUnit4 once the slice is "playable" and the next 3-5 units of code deserve their own test files). Today's recommendation deliberately does not add `addons/`.

### Option F — Headless `--quit` + console-output grep

The `godot-project-verification` skill describes this exact pattern (and its failure mode: "Godot exits 0 even when scripts fail to parse"). The `GameCoordinator` already prints `GC: Processing Day Ticks: <N>` on every tick, and `ManagementModule.initialize_module()` prints its own banner. A grep-based smoke like:

```bash
godot --path ./src/feudal-age/ --headless --quit > out.txt 2>&1
grep -q "GC: Processing Day Ticks: 5" out.txt && echo OK || echo FAIL
```

…is a fast gate for "the bootstrap doesn't crash and the timer is wired". **Keep it as a pre-step** — it's the cheapest possible "is the loop alive" check — but **do not make it the slice-success gate**: it does not prove `world_nodes[1].stockpile["Timber"]` actually changed. The skill's §7 spells out exactly why: "A scene can boot, all scripts parse, every autoload registers, every signal connects, the headless run returns 0 — and the simulation does absolutely nothing" because of duck-typed module contracts or empty/missing context resources. Grep catches parse + bootstrap. Domain-state assertion catches the rest.

---

## Chosen approach (concrete)

A **two-stage gate** in a single one-line wrapper:

1. **Stage 1 — Integrity gate (parse + autoload + bootstrap).** Reuse the existing recipe from the `godot-project-verification` skill (§1, the cache-then-verify two-step). This catches the cold-parse `class_name` storm and the silent-skip scenarios where modules never register. Sub-second on a warm cache.
2. **Stage 2 — Smoke test (real state mutation).** A new `extends SceneTree` script that boots the `GameCoordinator` scene, drives N ticks, snapshots `FiefStateResource.world_nodes[1].stockpile["Timber"]` before/after, asserts delta > 0, and `quit(0)` / `quit(1)` accordingly. Because it `instantiate()`s the real production scene, it exercises the same code path a player would.

**No new addons. No new dependencies. No CI runner required** (the script returns real exit codes, so any runner — `bash`, GitHub Actions, local terminal — gets pass/fail for free).

### What "playable" means in this codebase (precondition for the smoke)

The smoke script needs the slice to be in a state where ticks actually do production work. Per `ZoneNode.process_management_tick()`:

```
if current_tier == SettlementTier.WILDERNESS:
    return   # wilderness nodes are silent
```

And `_execute_production_and_labor()` only yields Timber when `woodcutters > 0` *and* the node has a completed building whose `blueprint.job_type == "woodcutter"`. So for the smoke to assert `stockpile["Timber"] > 0`, the node must (a) be `CAMP` or higher tier, and (b) have at least one completed woodcutter building with the assigned worker actually assigned by the workforce allocator. The slice must reach that state via `establish_camp()` + `order_building()` + enough ticks to finish construction before the assertion tick.

**Alternative for the first cut** (before building completion is wired into the slice): assert something that is mutated unconditionally on a non-WILDERNESS node — e.g. `local_workers.size() == 2` stays stable (proves the module ran without crashing and the workforce allocation didn't break invariants) or `canopy_density` decreased on the WILDERNESS-→-CAMP transition if canopy starts non-zero. Pick whatever the first-vertical-slice ships with; the smoke is parameterized by an asserted field, so swapping fields later is one line.

---

## Where the script lives

```
src/feudal-age/tests/
└── smoke_slice.gd          # the new file
```

Rationale:

- **`src/feudal-age/tests/`** — inside the Godot project root so the `--path` flag finds it as `res://tests/smoke_slice.gd`, matching how `src/feudal-age/test_gen.gd` already works. A repo-root `tests/` would require an absolute-path invocation and breaks the convention `test_gen.gd` already established.
- **Filename** `smoke_slice.gd` (not `test_smoke_slice.gd`) to avoid the Godot docs' `tests/test_*.gd` convention — that prefix is what the engine's *own* C++ doctest discovery looks for and would be misleading here (we are not using `--test`). Keep it greppable: any file matching `smoke_*.gd` is a runnable smoke.
- **One file, one assertion** is the rule for now. The ticket explicitly asks for the smallest possible thing.

(The repo-root `tests/` directory and the `addons/gut` / `addons/gdunit4` directories are deferred to the "introduce a real framework" ticket. Document that decision here so it doesn't get re-litigated.)

---

## How to invoke it

### Direct invocation (developer machine)

```bash
# From the repo root (gamedev-feudal/) on Windows / git-bash / MSYS:

# 1a. Pre-warm the global-class cache so cold-parse SCRIPT ERRORs don't poison the run
#     (this matches the godot-project-verification skill §1 two-step recipe)
GODOT=/c/Users/woodl/Godot_v4.6.2-stable_win64/godot
PROJECT=/c/Users/woodl/GitHub/gamedev-feudal/src/feudal-age

"$GODOT" --headless --editor --quit --path "$PROJECT"      # build .godot/global_script_class_cache.cfg
"$GODOT" --path "$PROJECT" --headless --quit               # integrity gate (grep for SCRIPT ERROR)

# 1b. Run the smoke
"$GODOT" --path "$PROJECT" --headless --script res://tests/smoke_slice.gd
echo "exit=$?"
```

The smoke script returns exit 0 on pass, non-zero on fail (assertion miss, missing node, unbootable scene).

### CI invocation (when a runner is added — `.github/workflows/smoke.yml`)

```yaml
- name: Run slice smoke
  working-directory: src/feudal-age
  run: |
    /c/Users/woodl/Godot_v4.6.2-stable_win64/godot --headless --editor --quit --path .
    /c/Users/woodl/Godot_v4.6.2-stable_win64/godot --path . --headless --script res://tests/smoke_slice.gd
```

GitHub Actions runs Windows runners with git-bash, so the absolute path syntax above works on both dev and CI. The `--script res://...` form is portable: same command works on Linux/macOS CI runners pointing at `godot` in `PATH`, by switching the path to `res://tests/smoke_slice.gd` (already portable) and the binary to `${{ matrix.godot }}`.

### Local one-liner (for "is the slice still playable right now?")

```bash
/c/Users/woodl/Godot_v4.6.2-stable_win64/godot \
  --path /c/Users/woodl/GitHub/gamedev-feudal/src/feudal-age \
  --headless --script res://tests/smoke_slice.gd && echo "SLICE OK" || echo "SLICE BROKEN"
```

---

## What it asserts

The minimum viable smoke does four things in order. Each is a hard precondition for the next; failing any one returns exit 1 with a distinct error line on stderr so a CI log makes the failure mode obvious without re-running locally.

### 1. Scene boots cleanly (parse + autoload + bootstrap)

```
- GameCoordinator.tscn instantiate() returns a non-null Node.
- The autoloads registered (ServiceLocator, EventBus) respond to get_*_service().
- ManagementModule and ManagementAPI appear as children of GameCoordinator.
- game_context (FiefStateResource) is non-null and has a `world_nodes` Dictionary field.
- world_nodes is populated by WorldInitializer: at least 5 entries with ids 1..5.
```

If any of these fail, the script `printerr()`s the specific missing piece and `quit(1)`. This is where the cold-parse storm from `godot-project-verification` §1 used to hide; running the cache-warm step before `--script` avoids it.

### 2. The simulation loop runs deterministically (no silent-skip)

```
- Drive N ticks via direct call to GameCoordinator._on_simulation_tick_elapsed(),
  NOT by waiting on the 3-second Timer (deterministic, sub-second runtime).
- After N=1 tick: at least one zone node processed without throwing
  (no SCRIPT ERROR, no Node-not-found in logs).
- Capture "GC: Processing Day Ticks: <N>" appears for the asserted N — belt and braces,
  also confirms game_coordinator's _current_game_day counter incremented.
```

This is the exact silent-skip guard the skill §7 calls out: if `game_context` is missing or empty, or a module doesn't match the `initialize_module`/`process_tick`/`get_save_snapshot` contract, `process_tick()` is a no-op and the log shows nothing useful. This assertion catches that.

### 3. Domain state actually mutated (the real success signal)

```
- Set node 1 (Ironwood Hollow) to CAMP via ManagementAPI.establish_camp(1).
- Either (a) inject a completed woodcutter building directly via test seam,
  or (b) call process_tick() enough times for construction_progress to clear.
- Snapshot stockpile["Timber"] before the assertion window.
- Drive M more ticks (e.g. M=5 day ticks → ~5 production ticks).
- Assert stockpile["Timber"] > before snapshot. On miss, print the before/after
  and which zone was checked, then quit(1).
```

The assertion field is parameterized — when the slice's first production loop lands (e.g. maybe canopy_density decay without requiring buildings, or maybe berries without buildings), this section is the only line that changes.

### 4. API surface responds (proves ManagementAPI is wired, not just loaded)

```
- ManagementAPI.get_node_inspection_data(1) returns a non-empty Dictionary.
- The returned dict's "timber_stock" matches the field we just asserted in step 3.
```

This catches the case where the FiefStateResource holds the right value but the API layer (which the UI depends on) reads from the wrong reference. Cheap insurance against a regression class that wouldn't surface in the in-game state alone.

### Output contract

The script emits, in order, one line per assertion on stdout, in this format (so any CI log parser can grep the pass count):

```
SMOKE PASS 1/4: scene booted, modules registered, 5 world_nodes
SMOKE PASS 2/4: 5 ticks driven, no errors, day counter advanced
SMOKE PASS 3/4: node 1 stockpile Timber: 0 -> 12
SMOKE PASS 4/4: get_node_inspection_data(1).timber_stock == 12
```

On any failure:

```
SMOKE FAIL 3/4: node 1 stockpile Timber: 0 -> 0 (expected > 0)
```

Then `quit(1)`. The `gc_verify.log` style of line-prefixed output is already a pattern in this repo (see the existing file at the repo root), so this fits the established convention.

---

## Risks & open questions for the implementer

1. **Timer-driven vs. directly-invoked ticks.** Calling `GameCoordinator._on_simulation_tick_elapsed()` directly is faster and deterministic, but couples the test to a private method name. Alternative: set `daily_tick_rate_seconds = 0.05` and `await get_tree().create_timer(N * 0.05).timeout`. Recommend direct invocation, with a comment noting the coupling, because determinism + speed matter more than the abstraction leak for a smoke.
2. **The CAMP transition prerequisite.** The current `process_management_tick()` early-returns on WILDERNESS. The smoke must establish a camp first. Confirm the slice's first delivery includes `establish_camp()` wired to the management UI; if not, the assertion has to wait or use a different field (see "What 'playable' means" above).
3. **Cold-cache on a brand-new clone.** Stage 1's cache-warm step is mandatory before the smoke on any runner that hasn't run the editor. The single-line CI invocation above includes both steps.
4. **Baseline screenshot diff is a deferred ticket, not part of this.** Listed here so it's not forgotten; not blocking.

---

## Summary table

| Approach | Fit for this ticket | Verdict |
|---|---|---|
| Manual play only | Catches nothing reproducible | Reject as primary gate |
| **Custom `extends SceneTree` smoke** | **Real state assertion, real exit code, no addons** | **Recommended** |
| Visual screenshot diff | Right for later, wrong for "did state mutate" | Defer |
| Godot's `--test` mode | Engine-internal C++ tests, not project logic | Reject (does not apply) |
| GUT / gdUnit4 | Right at ≥5 units, overkill at 1 | Defer to next ticket |
| Grep on `--quit` output | Cheap pre-check; doesn't prove state mutation | Keep as Stage 1, not Stage 2 |