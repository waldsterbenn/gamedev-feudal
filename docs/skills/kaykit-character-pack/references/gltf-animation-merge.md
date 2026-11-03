# GLTF character rigs + animation-library merge (Godot 4.x)

Asset packs often ship a character model GLB (skeleton + meshes, NO clips) separately from animation GLBs (clips + a throwaway mannequin mesh). The clips merge onto the character skeleton at runtime with no retargeting when bone names match. Verified for KayKit Adventurers; the recipe is pack-agnostic.

## Probe before wiring anything

Use a headless `SceneTree` probe (`extends SceneTree`, work in `_process() -> bool`) that instantiates each GLB and prints: node structure with classes, for every AnimationPlayer each animation's length / track count / first track path / loop mode, and mesh AABBs. The first track path reveals the shape the merge wiring must satisfy (e.g. `Rig_Medium/Skeleton3D:hips`).

Verify bone-name equality between the character GLB and the animation GLBs straight from the raw glTF JSON with Python (no Godot needed):

```python
import json, struct

def glb_json(path):
    with open(path, 'rb') as f:
        data = f.read()
    assert data[:4] == b'glTF'
    length = struct.unpack('<I', data[12:16])[0]
    return json.loads(data[20:20 + length])

j = glb_json('Character.glb')
joints = j['skins'][0]['joints']
print([j['nodes'][k].get('name') for k in joints])
```

Also read from the same JSON: whether the character embeds its texture (`images` entries without `uri` are buffer-embedded) and whether it has animations at all — character GLBs frequently have none, which means no AnimationPlayer node after import.

## Merge recipe

1. In the character `.tscn`: instance the model GLB as a child (e.g. named `Model`, with the pack's 180° yaw flip if the model faces +Z), and add an `AnimationPlayer` node with `root_node = NodePath("../Model")` so the imported track paths resolve against the model instance's internal hierarchy.
2. At runtime (a component's `_ready()`): build an `AnimationLibrary`; for each animation GLB, `load()`, `instantiate()`, recursively find its AnimationPlayer, copy every animation with `library.add_animation(name, anim)`, then `inst.free()` — the temp instance was never in the tree, so `free()`, not `queue_free()`.
3. Add the library: `if not _player.has_animation_library(""): _player.add_animation_library("", library)`.
4. Set `loop_mode = Animation.LOOP_LINEAR` on every looping clip AFTER the merge; it persists only for the session, so do it on every boot.
5. Play API: `_player.play(clip, blend_time, custom_speed)`. Re-calling `play()` with the SAME clip name does NOT restart it — position is preserved and the per-play custom speed is updated (verified: `current_animation_position` continuous across the re-call). Use that to update speed mid-clip while keeping stride phase. Never adjust a single clip's speed via the `AnimationPlayer.speed_scale` property: it is a GLOBAL multiplier on top of the per-play custom speed and compounds (two 5x plays → 25x).
6. Read the effective playback rate with `get_playing_speed()`, not `speed_scale` — the property stays 1.0 when speed was passed per-play, so tests asserting `speed_scale` fail wrongly.
7. Walk/run sync: export a per-clip reference map (in-world units/second each clip was authored for — walk ≈ 2, run ≈ 4 for Rig_Medium); callers pass their `move_speed` and the component sets `custom_speed = move_speed / reference`. A single global reference breaks the moment a second locomotion clip joins.

## State-driven wiring

Give the component `play_for_state(state_name)` backed by an exported state→clip Dictionary. The entity connects its StateMachine's `state_changed` signal to it in `_ready()`; states that need phase-level clips (move to target, then work) call `play_clip()` directly on entering the phase. States never touch the AnimationPlayer themselves.

## Pitfalls

- Never instance the animation GLB into a game scene — it drags the mannequin mesh in; harvest its Animation resources and free it.
- If tracks silently don't animate after the merge, the mismatch is almost always nesting: the player's `root_node` must point at the node whose children match the path prefix in the tracks (`Rig_Medium/Skeleton3D:...`).
- Imported clips default to `LOOP_NONE`.
- A visual scene shared by player and NPCs: search the scene tree for the scene path before rewriting it — swapping the model inside a shared scene changes every consumer, and a controller component may reference the scene root as a `Geometry` target whose semantics must stay intact.
- Verify a state change actually lands on the expected clip with a headless smoke test: instantiate the NPC scene, drive `change_state_by_path()`, and assert `AnimationPlayer.current_animation` per state.
