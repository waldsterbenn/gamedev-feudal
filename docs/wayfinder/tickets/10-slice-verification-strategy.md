---
status: open
type: research
blocked-by: []
---

# Research: how to verify a slice run succeeded

## Question

Once the slice is "playable," how do we know it actually worked? Options to weigh:

1. **Manual play** only — a human plays it and confirms. Simple but not reproducible; can't be CI'd.
2. **Headless smoke test** — a custom GDScript that boots the scene, fast-forwards N ticks, asserts that `FiefStateResource.world_nodes[1].stockpile["Timber"] > 0` after 30 ticks, exits with code 0. Reproducible.
3. **Visual screenshot diff** — boot the slice, render a frame, screenshot, compare to a baseline. Catches visual regressions.
4. **Integration test using Godot's `--test` mode** (if applicable in 4.6).

The decision: which combination do we use for the slice, and where do they live (`tests/`, `scripts/smoke/`, GitHub Action, etc.)? The skill "godot-project-verification" has hints — check it.

Output target: `docs/wayfinder/findings/10-slice-verification-strategy.md` with the chosen approach, the script path(s), and how to invoke them.

This is research because it's "what does the Godot 4.6 ecosystem support, and what fits this project's size?" rather than "build a thing."