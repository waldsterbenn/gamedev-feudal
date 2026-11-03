---
name: kaykit-character-pack
description: A low-poly character asset pack featuring 5 (+3 in EXTRA tier) fully rigged and animated adventurer characters with 25+ weapons and accessories.
license: CC0 (Public Domain)
compatibility: Godot 4.x, Feudal Game project
metadata:
  maintainer: "Kay Lousberg"
  license: "CC0 (Public Domain)"
  source: "https://kaylousberg.itch.io/kaykit-adventurers"
tags:
  - godot
  - plugin
  - feudal-age
---

## 3. KayKit Character Pack (Adventurers)
**Source:** https://kaylousberg.itch.io/kaykit-adventurers
**Maintainer:** Kay Lousberg
**License:** CC0 (Public Domain)

### What It Is
A low-poly character asset pack featuring 5 (+3 in EXTRA tier) fully rigged and animated adventurer characters with 25+ weapons and accessories.

### Contents
**Free Tier (5 characters):**
- Barbarian, Ranger, Mage, Rogue, Knight
- Various weapons/shields/bows/staffs/wands
- Single 1024×1024 gradient atlas texture
- FBX and GLTF formats

**EXTRA Tier ($7.95+):** 3 additional characters (Engineer, Druid, larger Barbarian) + alternative textures

**SOURCE Tier ($11.95+):** Blender source files (.blend)

### Technical Specifications
- **Format:** FBX, GLTF (compatible with Unity, Godot, Unreal, Roblox)
- **Texture:** Single 1024×1024 atlas (can be downsampled to 128×128 for mobile)
- **Polycount:** Low-poly optimized
- **Rigging:** Humanoid rig with basic movement animations
- **Animation Compatibility:** Works with free KayKit Character Animations pack

### Installation
1. Download from itch.io — the page needs a browser session and the direct file URL expires ~60 s, so follow `references/itchio-pack-download.md` for the working headless procedure.
2. Stage the zip in `/assets/original/kaykit-adventurers/` (read-only originals, git-ignored), then copy only the needed files into `src/feudal-age/assets/characters/kaykit/`.
3. Run a headless import pass (`godot --path <proj> --headless --editor --quit`) to generate `.import` files before first use.
4. Character `.glb` files embed their texture and import cleanly on default settings — no import tweaks needed.

### Verified rig facts (Godot 4.7 import, GLTF path)
- Shared rig `Rig_Medium`: 23 joints with names like `root`, `hips`, `spine`, `chest`, `head`, and `.l`/`.r` pairs of `upperarm/lowerarm/wrist/hand/handslot` and `upperleg/lowerleg/foot/toes`.
- Characters stand ~2.2 world units tall at scale 1.0.
- Models face **+Z** (glTF convention); Godot forward is −Z, so give the model child a 180° yaw flip (`Transform3D(-1,0,0,0,1,0,0,0,-1)`) when movement code uses `look_at`.
- Character GLBs ship with **no animations and no AnimationPlayer node**. The animation GLBs (`Rig_Medium_General`, `Rig_Medium_MovementBasic`) hold the clips, share identical bone names, and also carry a mannequin mesh — never instance them into a game scene; only harvest their Animation resources.
- Clip names — General: `Death_A/B` (+`_Pose`), `Hit_A/B`, `Idle_A/B`, `Interact`, `PickUp`, `Spawn_Air/Ground`, `T-Pose`, `Throw`, `Use_Item`. MovementBasic: `Jump_*`, `Running_A/B`, `T-Pose`, `Walking_A/B/C`.
- Clip track paths look like `Rig_Medium/Skeleton3D:hips`, relative to the AnimationPlayer's `root_node`.

### Using animations on a character
Follow `references/gltf-animation-merge.md` for the Godot integration recipe: AnimationPlayer `root_node` wiring, runtime AnimationLibrary merge onto the character skeleton, loop modes, walk-speed sync, and state-driven component wiring.

### Integration Notes
- CC0 license — unrestricted commercial use, no attribution required.
- Free tier has no dedicated peasant/villager body; pick the closest read for the role (the hooded rogue reads as a commoner).
- Multiple source packs share one rig family — verify bone-name equality between model and animation GLBs before assuming clips retarget.
