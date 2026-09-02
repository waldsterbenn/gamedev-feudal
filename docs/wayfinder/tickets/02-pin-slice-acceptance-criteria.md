---
status: in-progress
type: grilling
blocked-by: [01-lock-game-pillars]
---

# Pin the slice's gameplay loop and acceptance criteria

## Question

We agreed the destination is the smallest runnable build in which all five pillars have at least one observable beat. But "observable beat" needs sharpening.

What's the exact step-by-step that a player (and a headless integration check) should be able to do end-to-end?

Some shape:
1. Game launches. Player spawns at a sane position on Terrain3D.
2. Player presses Tab → management mode toggles. Zone anchors light up; mouse is visible.
3. Player clicks a `WILDERNESS` zone anchor → `ZoneInspectionMenu` opens.
4. Player clicks "Establish Camp" → that node's tier becomes `CAMP`; populants assigned to it visibly move toward it (or at least state-machine transitions to "AssignedWork").
5. Player clicks "Build" → a tent/forager_post appears in the node's buildings list with `is_completed: false`.
6. Over N game ticks (N small, like 3), the building's `construction_progress` advances and the populants switch from "builder" to their assigned "forager" / "woodcutter" job.
7. Player re-opens the inspection menu → timber / berries / mushrooms counts are visibly higher than at start; canopy bar is lower if woodcutters ran.
8. Optionally: player walks the player character close to a populant and confirms the populant is animated / not a T-pose cube.

The decision is what each step's *acceptance* is — must-haves vs. could-haves. Also: how many zones need to be in the slice (1 vs the current 5)? How many populants? How many building types?

This is grilling — the human gets to weigh in.