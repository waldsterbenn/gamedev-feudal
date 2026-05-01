# Slice 3 Asset Integration Plan — Viking Mini-Scene

> **Status:** Plan  
> **Goal:** Add exactly **3 assets from the POLYGON Vikings pack** to `slice3-peasant-character` to establish a Nordic coastal theme.  
> **Scope:** One prop, one building, one environment piece. Minimal, focused, runnable after each addition.  
> **Context:** Slice 3 has a greybox world (flat floor, 4 walls, a cube "gold chest"), a peasant player with state machine + interaction system, and a HUD.

---

## 1. Current Context

### Slice 3 State
| Feature | Status | Key Files |
|---|---|---|
| Player (Peasant) | ✅ Working | `scenes/player/Player.tscn`, `scripts/player/Player.gd` |
| State Machine | ✅ Working | `scripts/components/StateMachine.gd`, `scripts/player/states/` |
| Health Component | ✅ Working | `scripts/components/HealthComponent.gd` |
| Interaction System | ✅ Working | `scripts/components/InteractableComponent.gd`, `InteractorComponent.gd` |
| HUD | ✅ Working | `scenes/ui/HUD.tscn` |
| World | ⚠️ Greybox | `scenes/world/World.tscn` (flat box floor, 4 box walls, box chest) |
| EventBus / GameManager | ✅ Working | `scripts/managers/EventBus.gd`, `GameManager.gd` |

### Source Pack
**POLYGON Vikings** (`/assets/Synthy/SynthyVikingsPackage/`)
- Low-poly, atlas-textured, consistent with Adventure pack characters already in use
- Main texture: `Texture_01.png`
- Character skins: `Characters_Black.png`, `Characters_Brown.png`, `Characters_White.png`

---

## 2. Asset Selection

### Selected Assets

| Slot | Asset | File (relative to pack root) | Rationale |
|------|-------|------------------------------|-----------|
| **Prop** | Chest | `Source_Files/FBX/SM_Prop_Chest_01.fbx` | Direct replacement for the greybox "Gold Chest" cube. Already has an `InteractableComponent` wired up — swapping the mesh preserves all gameplay logic. Iconic, recognizable, and immediately improves the interaction moment. |
| **Building** | Longhouse Base | `Source_Files/FBX/SM_Bld_Base_01.fbx` | The quintessential Viking structure. Single-piece mesh, no complex assembly needed. Gives the player immediate environmental context ("I am in a Viking settlement"). Placed as a static landmark the player can walk around. |
| **Environment** | Rock | `Source_Files/FBX/SM_Env_Rock_01.fbx` | Simple, versatile, fills negative space. Adds natural ground variation without needing terrain systems. Multiple variants exist (`Rock_01`–`Rock_06`, `Rock_Large_01`–`03`, `Rock_Pile_01`–`03`) so we can scatter 3–4 instances from the same source file for visual variety. |

### Why These Three?
- **Narrative cohesion:** Chest + Longhouse + Rocks = "a coastal Viking camp with stored loot"
- **Gameplay integration:** The chest is already an interactable; the building and rocks add collision boundaries to navigate around
- **Low risk:** All are static meshes, no animations, no rigging, no custom shaders
- **Scalable:** If we want more later, the Vikings pack has 766 assets to draw from using the same atlas

---

## 3. Step-by-Step Plan

### Step 1: Copy Assets from Master Library

**Policy reminder:** `/assets/Synthy/` is READ-ONLY. Copy into slice3's asset folder.

```bash
# Create target directories
mkdir -p src/slice3-peasant-character/assets/models/props
mkdir -p src/slice3-peasant-character/assets/models/buildings
mkdir -p src/slice3-peasant-character/assets/models/environment
mkdir -p src/slice3-peasant-character/assets/textures

# Copy the 3 meshes
# Prop
cp assets/Synthy/SynthyVikingsPackage/POLYGON_Vikings_Source_Files_v3/Source_Files/FBX/SM_Prop_Chest_01.fbx \
   src/slice3-peasant-character/assets/models/props/

# Building
cp assets/Synthy/SynthyVikingsPackage/POLYGON_Vikings_Source_Files_v3/Source_Files/FBX/SM_Bld_Base_01.fbx \
   src/slice3-peasant-character/assets/models/buildings/

# Environment
cp assets/Synthy/SynthyVikingsPackage/POLYGON_Vikings_Source_Files_v3/Source_Files/FBX/SM_Env_Rock_01.fbx \
   src/slice3-peasant-character/assets/models/environment/

# Copy texture atlas (shared by all 3)
cp assets/Synthy/SynthyVikingsPackage/POLYGON_Vikings_Source_Files_v3/Source_Files/Textures/Texture_01.png \
   src/slice3-peasant-character/assets/textures/
```

### Step 2: Import into Godot

Open the slice3 project in Godot (or let Godot auto-import on first reference). The `.fbx.import` files will be generated automatically.

**Verify:** In the FileSystem dock, confirm:
- `res://assets/models/props/SM_Prop_Chest_01.fbx` shows a preview
- `res://assets/models/buildings/SM_Bld_Base_01.fbx` shows a preview
- `res://assets/models/environment/SM_Env_Rock_01.fbx` shows a preview
- No pink/missing textures (means `Texture_01.png` is found)

### Step 3: Replace the Gold Chest (Prop)

**Target file:** `scenes/world/World.tscn`

1. Open `World.tscn`
2. Select the `GoldChest` node
3. Delete its child `MeshInstance3D` (the grey cube)
4. Add the imported `SM_Prop_Chest_01.fbx` as a child of `GoldChest`
5. Adjust transform:
   - Position: `Vector3(0, 0, 0)` (relative to parent)
   - Scale: verify it matches the collision box; adjust if the chest is too large/small
6. Keep `CollisionShape3D` — resize the `BoxShape3D` to snugly fit the chest mesh dimensions
7. Keep `InteractableComponent` with `interaction_name = "Chest"` — all gameplay logic preserved

**Collision sizing tip:** The chest is likely ~1m wide × 0.6m tall × 0.5m deep. Set `BoxShape3D.size` accordingly.

### Step 4: Add the Longhouse (Building)

1. In `World.tscn`, create a new `Node3D` named `Buildings`
2. Add `SM_Bld_Base_01.fbx` as a child of `Buildings`
3. Set transform:
   - Position: `Vector3(-8, 0, -8)` (offset from center, near a corner)
   - Rotation: `Vector3(0, 45, 0)` (angled toward the player spawn for a nice silhouette)
   - Scale: `Vector3(1, 1, 1)` (verify in-editor)
4. Add collision so the player can't walk through walls:
   - Add `StaticBody3D` as sibling or parent of the mesh
   - Add `CollisionShape3D` with `BoxShape3D`
   - Size and position the box to approximate the longhouse footprint
   - **Do NOT** use "Create Convex Collision Sibling" — use a manually placed primitive box for performance

### Step 5: Scatter Rocks (Environment)

1. In `World.tscn`, create a new `Node3D` named `EnvironmentProps`
2. Drag `SM_Env_Rock_01.fbx` in 3 times (or duplicate the node)
3. Position instances around the scene perimeter:
   - Rock A: `Vector3(10, 0, 5)`, `Rotation(0, 30, 0)`, `Scale(1.2, 1.2, 1.2)`
   - Rock B: `Vector3(-12, 0, 8)`, `Rotation(0, 120, 0)`, `Scale(0.8, 0.8, 0.8)`
   - Rock C: `Vector3(5, 0, -12)`, `Rotation(0, 200, 0)`, `Scale(1.5, 1.5, 1.5)`
4. **Collision:** Add `StaticBody3D` + `BoxShape3D` or `SphereShape3D` to each rock so the player can walk up to / around them. Keep shapes loose (no need for pixel-perfect).

### Step 6: Remove the Greybox Walls (Optional but Recommended)

The 4 box walls (`NorthWall`, `SouthWall`, `EastWall`, `WestWall`) were training wheels for slice1. With a longhouse and rocks creating natural boundaries, we can:

- **Option A:** Delete all 4 walls → open space feels better
- **Option B:** Keep walls but retexture them with a Viking-appropriate material (out of scope for this plan)
- **Option C:** Replace walls with fence props from the Vikings pack (e.g., `SM_Prop_Fence_Wood_01`) — future slice material

**Recommendation:** Option A — delete the walls. The longhouse and rocks provide enough visual containment.

---

## 4. Files Likely to Change

| File | Change |
|---|---|
| `src/slice3-peasant-character/scenes/world/World.tscn` | Restructure: delete cube chest mesh, add chest/building/rock nodes, possibly remove walls |
| `src/slice3-peasant-character/assets/models/props/SM_Prop_Chest_01.fbx` | **New** — copied from Vikings pack |
| `src/slice3-peasant-character/assets/models/buildings/SM_Bld_Base_01.fbx` | **New** — copied from Vikings pack |
| `src/slice3-peasant-character/assets/models/environment/SM_Env_Rock_01.fbx` | **New** — copied from Vikings pack |
| `src/slice3-peasant-character/assets/textures/Texture_01.png` | **New** — shared Viking atlas |
| `src/slice3-peasant-character/assets/models/props/*.fbx.import` | **Auto-generated** by Godot |
| `src/slice3-peasant-character/assets/models/buildings/*.fbx.import` | **Auto-generated** by Godot |
| `src/slice3-peasant-character/assets/models/environment/*.fbx.import` | **Auto-generated** by Godot |

---

## 5. Tests / Validation

After each step, run:

1. **Headless integrity:**
   ```bash
   godot --path ./src/slice3-peasant-character/ --headless --quit
   ```
   Exit code must be `0`.

2. **MCP run + log check:**
   - `run_project` on slice3
   - `get_debug_output`
   - Zero red errors

3. **Gameplay checks:**
   - Player spawns at `(0, 0.5, 0)`
   - WASD movement works
   - Player **cannot** walk through the longhouse (collision test)
   - Player **can** walk up to the chest and press `E` to interact
   - Rocks block movement (loose collision is fine)

4. **Visual checks:**
   - Chest renders with Viking texture (not pink)
   - Longhouse is visible and properly oriented
   - Rocks are scattered naturally, not floating
   - Lighting/shadows are consistent

---

## 6. Risks & Mitigations

| Risk | Mitigation |
|---|---|
| **Pink textures** | Ensure `Texture_01.png` is copied to `slice3/assets/textures/`. Godot's FBX importer looks for textures relative to the FBX or in the project root. If still pink, check the `.fbx.import` file for texture path hints. |
| **Chest too big/small** | Adjust the chest mesh's `scale` in the scene, then resize the `CollisionShape3D` to match. The `InteractableComponent`'s `Area3D` collision should also be resized. |
| **Longhouse scale is wrong** | Viking assets are typically 1 unit = 1 meter, same as the peasant character. If the longhouse dwarfs the player, scale down to `Vector3(0.5, 0.5, 0.5)` and re-evaluate. |
| **Player gets stuck on rocks** | Use generous `SphereShape3D` or large `BoxShape3D` for rock collision — don't try to match the rock shape exactly. If still sticky, reduce collision shape height (y-axis) so the player slides off. |

---

## 7. Future Expansion (Out of Scope)

If this mini-scene feels good, the Vikings pack has immediate follow-ups using the same atlas:

- **More buildings:** `SM_Bld_Roof_01` (place on top of `Base_01`), `SM_Bld_Guard_Tower_01`, `SM_Bld_Wharf_01`
- **More props:** `SM_Prop_Barrel_Half_01`, `SM_Prop_Crate_Open_01`, `SM_Prop_Anvil_01`, `SM_Prop_TorchStick_01`, `SM_Prop_Wagon_01`
- **More environment:** `SM_Env_Tree_Pine_01`, `SM_Env_Beach_01`, `SM_Env_Dirt_Mound_01`, `SM_Env_Rock_Pile_01`
- **Characters:** Viking Chief, Warrior, Shieldmaiden — drop-in NPCs using the same rig system as the Peasant

---

## 8. Success Criteria

- [ ] `SM_Prop_Chest_01.fbx` replaces the greybox cube in `GoldChest` and remains interactable
- [ ] `SM_Bld_Base_01.fbx` (longhouse) is visible in the world with working collision
- [ ] At least 3 instances of `SM_Env_Rock_01.fbx` are scattered with working collision
- [ ] All assets render with correct textures (no pink)
- [ ] Project runs headless with exit code 0
- [ ] No new errors in MCP debug output

---

*Plan prepared for focused Viking asset integration into slice3.*
