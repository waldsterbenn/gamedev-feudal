---
name: humanizer
description: A 3D character creation system based on MakeHuman and MPFB2, allowing
  procedural generation of humanoid characters with extensive customization opt...
license: Unknown (likely CC0 for assets)
compatibility: Godot 4.x, Feudal Game project
metadata:
  repository: https://github.com/NitroxNova/humanizer
  wiki: https://github.com/NitroxNova/humanizer/wiki
  maintainer: NitroxNova (ReignBowGames)
  version: v2.1.2 (Godot 4.3), v3 in development (Godot 4.4+)
  license: Unknown (likely CC0 for assets)
tags:
- godot
- plugin
- feudal-game
---

# Humanizer
**Repository:** https://github.com/NitroxNova/humanizer
**Wiki:** https://github.com/NitroxNova/humanizer/wiki
**Maintainer:** NitroxNova
**Version:** v2.1.2 (Godot 4.3), v3 in development (Godot 4.4+)
**License:** Unknown (likely CC0 for assets)

### What It Is
A 3D character creation system based on MakeHuman and MPFB2, allowing procedural generation of humanoid characters with extensive customization options.

### How It Works
Humanizer consists of:
- **Core Plugin:** Handles character generation, rigging, and animation retargeting
- **Asset System:** Base human models, clothing, and body parts from MakeHuman
- **Import Pipeline:** Converts MakeHuman assets (MHCLO, MHMAT, OBJ) to Godot-compatible formats
- **Authoring Tools:** In-editor interface for character customization

The system uses shape keys (over 1000+) for morph-based customization of weight, height, gender, race, and age.

### Installation (v2)
1. Download v2.1.2 release from GitHub
2. Extract and copy the `addons` folder to your project
3. Enable both `Humanizer` and `HumanizerGlobal` plugins in Project Settings
4. Reload the project if needed
5. Test with `addons/humanizer/scenes/tests/character3d.tscn`

### Version Compatibility
| Godot Version | Humanizer Version | Branch       |
|---------------|-------------------|--------------|
| 4.3           | v2.x              | main         |
| 4.4+          | v3 (dev)          | Requires separate assets |

**v3 Architecture:** Separate import plugin, authoring plugin, and asset repository (`humanizer_assets`)

### Key Features
- Fully customizable character weight/height/gender/race/age
- 1000+ shape keys for unique character generation
- Mixamo animation compatibility with retargeted rigs
- Facial mocap capability on standard rig
- Bone-attachable clothing and body parts
- Eye/hair/skin color overlay system
- Physical ragdolls
- CC0-licensed base assets from MakeHuman

### Usage Workflow
1. **Character Creation:** Use the Authoring Scene to generate base characters
2. **Asset Import:** Place MakeHuman assets in `assets/clothes/` or `assets/body_parts/`
3. **Equipment Attachment:** Use `asset_import` node to import and attach clothing
4. **Rigging:** Follow Rigging Equipment guide for bone attachment
5. **Animation:** Import Mixamo animations using the retargeting system

### Code Integration
```gdscript
# Loading a Humanizer character programmatically
var humanizer_character = preload("res://addons/humanizer/scenes/character3d.tscn").instantiate()
add_child(humanizer_character)

# Accessing shape key controls
# (Specific API documentation lacking - need to examine source)
```

**Recommended Companion:** Jolt Engine for Godot for improved physics
