---
status: open
type: research
blocked-by: []
---

# Audit 3D asset inventory in the repo

## Question

What 3D assets are actually available in this repo? The architecture docs say we use KayKit characters and AmbientCG / PolyHaven textures, but I need ground truth:

1. **What characters / meshes** are committed under `Assets/` and `src/feudal-age/assets/`? Specifically: peasant / NPC character prefabs, building prefabs (tents, huts, charcoal stacks), tree prefabs?
2. **What texture files** exist? Are there PBR diffuse / normal maps for ground, wood, stone?
3. **Are any of these already imported** (have `.import` sidecars) into the Godot project, or are they raw dumps in `/assets/original/`?
4. **Is the `PeasantCharacter.tscn`** referenced from `src/feudal-age/scenes/characters/` a full rigged character or a placeholder cube?
5. **License situation** — what's permitted for use / redistribution?

Output target: a single markdown report at `docs/wayfinder/findings/04-audit-3d-assets.md` listing every committed asset file path, its size, its kind (mesh / texture / audio / other), and whether it's imported into Godot. Plus a one-paragraph summary at the top.

This feeds into the building-blueprints ticket and into the slice's visual fidelity decision.