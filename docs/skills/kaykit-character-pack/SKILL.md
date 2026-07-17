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
1. Download from itch.io (name your own price)
2. Extract to project assets directory
3. Import GLTF files through Godot's import system
4. Configure materials and animations as needed

### Usage in Godot
```gdscript
# Basic character instantiation
var adventurer_scene = preload("res://assets/kaykit/adventurers/barbarian.gltf")
var character = adventurer_scene.instantiate()
add_child(character)

# Accessing animations
var animation_player = character.get_node("AnimationPlayer")
animation_player.play("run")

# Equipment attachment
# Accessories are separate mesh files that can be parented to bone attachments
```

### Integration Notes
- Characters use a single gradient-based texture atlas
- Materials are PBR-ready but may need adjustment for Godot's lighting
- Animations are basic; consider KayKit Character Animations pack for more variety
- CC0 license allows unrestricted commercial use (no attribution required)

**Insufficient Information:**
- Specific bone naming conventions not documented
- No Godot-specific import settings provided
- Animation state machine examples lacking
