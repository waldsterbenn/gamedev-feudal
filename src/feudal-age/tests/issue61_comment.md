## Root cause found

All 9 components **do** register — but every one registers under key `0`, so they collide in `_registered_populants` and only the last write survives. The "8 missing" and the "stale id=0 entry" are the same bug.

### Mechanism (verified with instrumented debug scripts)

1. `NPC.tscn` contains **no** `ManagementPopulantComponent` node. It is created dynamically in `scripts/characters/NPC.gd:22-25` (`_ready()`):
   ```gdscript
   management_comp = ManagementPopulantComponent.new()
   management_comp.name = "ManagementPopulantComponent"
   add_child(management_comp)          # <-- child's _ready() fires HERE, synchronously
   ```
2. Because the NPC is already inside the tree when `add_child()` is called, the new component's `_ready()` runs immediately (`scripts/management/components/ManagementPopulantComponent.gd:17-21`), calling `api.register_populant_component(self)`.
3. At that moment `management_comp.character_id` is still the default `0`. The ID alignment in `NPC.gd:28-30` happens **after** `add_child()`, so it corrects the component's own `character_id` (that's why the debug dump shows correct 1–9 on the nodes) but the ManagementAPI dictionary key was already recorded as `0` — and it is never re-keyed.
4. `ManagementAPI.register_populant_component()` (`scripts/management/ManagementAPI.gd:17-18`) does `_registered_populants[comp.character_id] = comp`, so all 9 registrations overwrite dictionary key `0`. Final state: exactly one entry, keyed `0`, holding the component of the **last** spawned NPC — matching the reported `id=0 ... @CharacterBody3D@23` path byte-for-byte.

### Evidence

- Instrumented poll of `ManagementAPI._registered_populants` from frame 1: registration snapshot is `{0: <instance of the char_id=9 component on @CharacterBody3D@23>}` and never changes through frame 60.
- `find_children("ManagementPopulantComponent")` returns 9 live, in-tree, ready components with `character_id` 1–9 — all attached to valid NPC roots (1 on `NPC`, 8 on auto-named `@CharacterBody3D@*` bodies; the auto-names come from the prefab root being instantiated before its `name` is assigned, unrelated to the bug).
- No script compile errors in the normal run path (the `InteractableComponent`/`ServiceLocator` compile errors seen under `--script` mode are an autoload-resolution artifact of headless `--script` runs, not the cause).

Side note (not the cause): `scenes/characters/NpcPeasant.tscn` references missing `scripts/characters/NpcPeasant.gd`, but that prefab is unused — only `NPC.tscn` is wired as `npc_prefab` in `World.tscn`. Worth cleaning up separately.

### Proposed fix (not implemented)

Minimal, one file — `scripts/characters/NPC.gd` `_ready()`: set the ID **before** `add_child()` so registration uses the correct key:

```gdscript
management_comp = get_node_or_null("ManagementPopulantComponent") as ManagementPopulantComponent
if not management_comp:
    management_comp = ManagementPopulantComponent.new()
    management_comp.name = "ManagementPopulantComponent"
    management_comp.character_id = id if id != -1 else name.hash()  # BEFORE add_child
    add_child(management_comp)
# keep the existing post-add alignment for a scene-provided component with id <= 0
```

Robustness improvements worth doing in the same pass (recommend):

1. **`scripts/management/components/ManagementPopulantComponent.gd`** — make registration re-key safe: in `_ready()` also handle late ID changes, e.g. expose `func set_character_id(v: int)` that re-keys the registry (`api.unregister(0); api.register(self)`), or simply defer registration one frame: `call_deferred("_register")` so any `_ready()`-time ID setup completes first.
2. **`scripts/world/NPCCoordinator.gd`** (`create_npc()`, ~line 50): the pre-`add_child` ID sync looks up `npc_instance.get_node_or_null("ManagementPopulantComponent")` — this always returns null today since the component doesn't exist until `NPC._ready()` creates it. After fix #1's reorder it should be moved *after* `NPC._ready()` runs (it currently relies on `npc.id` being set before `add_child`, which is fine), or replaced by reading `npc_instance.management_comp` post-add.
3. Optional hygiene: remove the dynamic-creation fallback entirely by adding a `ManagementPopulantComponent` node to `scenes/characters/NPC.tscn` (explicit scene wiring beats runtime creation and makes the pre-`add_child` ID sync in NPCCoordinator actually work).
4. Delete or repair the dead `scenes/characters/NpcPeasant.tscn` (missing script) — unrelated but it's a load-time landmine.

Acceptance re-check after fix: `tests/debug_populants.gd` should print `registered: 9` with keys 1–9, correct qualifications and lord assignments; `tests/smoke_slice.gd` woodcutter assignment should then succeed.

Debug scripts added during investigation (throwaway, safe to delete): `tests/debug_invest_reg.gd`, `tests/debug_invest_cls.gd`, `tests/debug_invest_frames.gd`.
