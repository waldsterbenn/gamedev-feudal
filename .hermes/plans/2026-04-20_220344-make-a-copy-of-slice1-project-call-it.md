# Plan: Copy slice1 to slice3 and implement peasant character

## Goal
Create a new vertical slice `slice3` (named `slice3-peasant-character`) as a copy of `slice1-basic-game`, then replace the player's capsule mesh with a peasant character model (from the POLYGON Adventure Pack) and integrate skeletal animations.

## Current Context / Assumptions
- Source slice: `src/slice1-basic-game/`
  - Player scene: `scenes/player/Player.tscn`
  - Player script: `scripts/player/Player.gd`
  - State machine with idle, moving, jump states
  - Third-person controller (`ThirdPersonControler3D`) using a `MeshInstance3D` as Geometry
  - No animation system currently
- Asset source: `/home/ls/gamedev-feudal/assets/Synthy/SynthyAdventurePackage/POLYGON_Adventure_Pack_SourceFiles_v4/SourceFiles/`
  - Contains FBX files for characters, including `SK_Character_Human_Peasant.fbx` (likely skeletal mesh with animations)
  - Textures in `Textures/` directory
- Original Master Policy: original assets are read‑only; we must copy needed files into the slice's own `assets/` directory.

## Proposed Approach
1. Copy `slice1-basic-game` to `slice3-peasant-character` (or `slice3` if naming convention demands).
2. Update `project.godot` to reflect the new slice name.
3. Copy required FBX and texture files into `slice3‑peasant‑character/assets/`.
4. Import the peasant FBX into Godot, adjusting import settings for materials and animations.
5. Create a separate `PeasantCharacter.tscn` scene that contains the imported mesh, skeleton, and an `AnimationPlayer` with idle/walk/jump animations.
6. Modify `Player.tscn`:
   - Replace the existing `MeshInstance3D` node with an instance of `PeasantCharacter.tscn`.
   - Update the `ThirdPersonControler3D`'s `Geometry` property to point to the mesh instance inside the peasant scene.
   - Add an `AnimationPlayer` node (if not already part of the peasant scene) and wire animation triggers to the state machine.
7. Extend the existing state scripts (`PlayerIdleState.gd`, `PlayerMoveState.gd`, `PlayerJumpState.gd`) to play the appropriate animations.
8. Validate the slice: run the project, test movement, check animations, and ensure no regressions.

## Step‑by‑Step Plan

### 1. Copy the slice
```bash
cp -r src/slice1-basic-game src/slice3-peasant-character
```

### 2. Update project configuration
Edit `src/slice3-peasant-character/project.godot`:
- Change `config/name` to `"slice3-peasant-character"` (or `"slice3"` as requested).
- Update `run/main_scene` if needed (should stay `"res://scenes/world/World.tscn"`).

### 3. Prepare asset directory
Create asset folder structure:
```bash
mkdir -p src/slice3-peasant-character/assets/characters/peasant
```
Copy required files from the original asset pack:
- `Character_Files/SK_Character_Human_Peasant.fbx`
- Possibly the corresponding textures from `Textures/` (need to identify which textures are referenced by the FBX).
- Use `MaterialList_PolygonAdventure.txt` as a reference.

### 4. Import the peasant model
Open the slice in Godot (via MCP `launch_editor`). The FBX will be auto‑imported.  
Potential import settings to adjust:
- **Mesh**: generate collision shape (simplify to capsule/box for player collision).
- **Materials**: keep imported materials; ensure textures are found.
- **Animations**: if the FBX contains animation tracks, import them as separate `AnimationLibrary` resources.

### 5. Create a reusable peasant character scene
Create a new scene `PeasantCharacter.tscn` under `scenes/characters/`:
- Root node: `Node3D`
- Add imported mesh as a child (likely a `MeshInstance3D` with a skeleton).
- Add an `AnimationPlayer` node, load the imported animations.
- Create animation tree or simple script to manage animation blending.

### 6. Integrate the peasant into the player scene
Open `Player.tscn`.  
- Remove the existing `MeshInstance3D` node (but keep its `CollisionShape3D`).
- Instance `PeasantCharacter.tscn` as a child of the player node.
- Set the `ThirdPersonControler3D`'s `Geometry` property to point to the mesh instance inside the peasant scene (e.g., `$PeasantCharacter/Armature/Skeleton3D/MeshInstance3D`).
- Adjust the `CollisionShape3D`'s shape and position to match the peasant's bounds (may need a new `CapsuleShape3D` or `BoxShape3D`).

### 7. Connect animations to the state machine
Modify the state scripts to play animations when entering/exiting states:
- `PlayerIdleState.gd`: play idle animation.
- `PlayerMoveState.gd`: play walk/run animation.
- `PlayerJumpState.gd`: play jump animation (or keep idle/walk while airborne).

Add an `AnimationPlayer` reference to the player script and pass it to the states (or use signals).

### 8. Validation & testing
- Run the project via MCP `run_project`.
- Check debug output with `get_debug_output`.
- Perform headless validation: `godot --path ./src/slice3-peasant-character --headless --quit`
- Test movement, jumping, camera follow, and that animations transition correctly.

### 9. Cleanup & documentation
- Remove any unused assets from the slice.
- Update `README.md` or `docs/` if needed.
- Ensure the slice follows the project's architectural standards (component‑based, state machines, signals).

## Files Likely to Change
- `src/slice3-peasant-character/project.godot`
- `src/slice3-peasant-character/scenes/player/Player.tscn`
- `src/slice3-peasant-character/scripts/player/Player.gd` (maybe add animation reference)
- `src/slice3-peasant-character/scripts/player/states/PlayerIdleState.gd`
- `src/slice3-peasant-character/scripts/player/states/PlayerMoveState.gd`
- `src/slice3-peasant-character/scripts/player/states/PlayerJumpState.gd`
- New: `src/slice3-peasant-character/scenes/characters/PeasantCharacter.tscn`
- New: `src/slice3-peasant-character/assets/characters/peasant/` (imported .fbx, .import, textures)

## Tests / Validation
- Manual playtest: verify peasant model renders, moves, animates.
- Headless run: ensure no import errors or script errors.
- Debug output: watch for warnings about missing textures, nodes, or animations.
- Performance: profile with the built‑in profiler to confirm no frame drops.

## Risks, Tradeoffs, and Open Questions
1. **FBX import complexity**: The FBX may contain multiple meshes, materials, or unsupported features. May need to simplify or export as glTF.
2. **Animation integration**: The existing state machine may need extension to handle animation blending and transitions. Could require a separate `AnimationTree`.
3. **Collision shape**: The peasant's silhouette may not match a simple capsule; may need a compound shape or a simplified approximation.
4. **Third‑person controller compatibility**: The controller expects a single `MeshInstance3D` as Geometry; peasant scene may have a hierarchy. Might need to adjust the controller script or point to the correct node.
5. **Texture paths**: Textures referenced in the FBX may be absolute paths; need to ensure they are copied and relative to the slice.
6. **Naming**: Should the slice be called `slice3` (as requested) or `slice3‑peasant‑character`? Follow existing pattern (`slice1‑basic‑game`, `slice2‑terrain‑textures`).

## Decision Points
- Confirm with user: naming of slice (`slice3` vs `slice3‑peasant‑character`).
- Confirm with user: whether to keep capsule collision or create a custom shape.
- Confirm with user: whether to implement animation tree or simple `AnimationPlayer` triggers.

## Next Steps
After plan approval, execute the steps using Godot MCP tools and terminal commands, following the `godot‑slice‑modification` skill and `AGENTS.md` manifest.