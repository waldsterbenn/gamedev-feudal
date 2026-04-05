# Asset Naming Conventions & Formats

> **Purpose:** Prevent the inevitable chaos of inconsistently named files that nobody can find or reuse.
> **Applies to:** All art, audio, and imported assets. Follow this from day one.

---

## Core Rules

1. **Lowercase only.** No spaces. No special characters except hyphens and underscores.
2. **Use hyphens to separate logical groups** and **underscores to separate modifiers**. Example: `bg_forest-tileset_01.png`
3. **Prefix by asset type.** So you can type `spr_` or `sfx_` and see everything grouped together in file browsers.
4. **Version with numbers at the end, not "final_v2_FINAL"** Use `01`, `02`, `03`. When a file is definitive, the last version number is the only one that should remain. Delete old versions immediately.
5. **Be specific but not verbose.** `spr_player-run` is clear. `spr_player-character-running-animation-v2` is not.

---

## Prefixes

### Sprites / 2D Art

| Prefix | Meaning | Examples |
|--------|---------|---------|
| `spr_` | General sprite | `spr_knight-idle`, `spr_castle-exterior` |
| `tile_` | Tilemap tile | `tile_grass-01`, `tile_wall-corner` |
| `bg_` | Background | `bg_village-day`, `bg_throne-room` |
| `ui_` | UI element | `ui_button-normal`, `ui_health-frame`, `ui_panel-inventory` |
| `fx_` | Effect / particle sprite | `fx_blood-spatter`, `fx_dust-cloud` |
| `portrait_` | NPC / character portrait | `portrait_lord-edric`, `portrait_merchant-anna` |
| `icon_` | Small icon | `icon_gold`, `icon_sword-iron`, `icon_shield` |

### 3D Models (if applicable)

| Prefix | Meaning | Examples |
|--------|---------|---------|
| `model_` | General 3D model | `model_sword-broad`, `model_oak-tree` |
| `arm_` | Armature / skeleton | `arm_skeleton-human`, `arm_skeleton-horse` |

### Audio

| Prefix | Meaning | Examples |
|--------|---------|---------|
| `sfx_` | Sound effect | `sfx_sword-swing`, `sfx_door-creak`, `sfx_coin-collect` |
| `sfx-ui_` | UI feedback sound | `sfx-ui_click`, `sfx-ui_hover`, `sfx-ui_confirm` |
| `sfx-foley_` | Footsteps, cloth, ambient movement | `sfx-foley_leather-step`, `sfx-foley_mail-rustle` |
| `amb_` | Ambient / looping | `amb_forest-wind`, `amb_tavern-crowd`, `amb_rain-heavy` |
| `music_` | Background music | `music_menu-main`, `music_battle-intense`, `music_explore-forest` |

### Animation (if separate from sprite atlases)

| Prefix | Meaning |
|--------|---------|
| `anim_` | Animation data / state machine files |

---

## Format Standards

### Images

| Use Case | Format | Notes |
|----------|--------|-------|
| Sprites / tiles / UI | **PNG** (lossless, transparency) | Godot default. Always PNG. |
| Backgrounds / paintings (no transparency) | **JPG** (80-90% quality) | Smaller file size. Only if PNG is unnecessary. |
| Source files | **Native** (.kra, .psd, .aseprite) | Keep in `assets/art/source/` -- not imported by Godot |
| Texture atlases | **PNG** | Group related sprites into atlases when possible for performance |

### Audio

| Use Case | Format | Notes |
|----------|--------|-------|
| SFX / Foley | **WAV** (44.1kHz, 16-bit or 24-bit) | Godot compresses on import. Keep source high quality. |
| Music | **OGG Vorbis** | Loopable. Godot handles OGG streaming efficiently. |
| Ambient loops | **OGG Vorbis** | Set loop points in Godot importer. Ensure seamless loop in audio editor. |

### Video (if applicable)

| Use Case | Format | Notes |
|----------|--------|-------|
| Cutscenes / cinematics | **WebM** | Godot supports WebM natively. Use VP9 codec. |

---

## Animation Naming

For frame-by-frame or sprite-sheet animations:

```
spr_{character}-{animation}-{frame-number}.png
```

Examples:
- `spr_knight-idle-01.png` through `spr_knight-idle-04.png`
- `spr_knight-attack-01.png` through `spr_knight-attack-06.png`
- `spr_knight-run-01.png` through `spr_knight-run-08.png`

If using **sprite sheets** (single image with multiple frames):

```
spr_{character}-{animation}.png
```
And include a companion JSON or the Godot scene file defines the frame regions.

---

## State and Variation Naming

When a character or object has visual states:

```
spr_{entity}-{state}-{orientation-if-needed}
```

Examples:
- `spr_gate-closed.png`, `spr_gate-open.png`, `spr_gate-broken.png`
- `spr_chest-{closed,open,empty}.png`
- `spr_npc-merchant-neutral.png`, `spr_npc-merchant-angry.png`, `spr_npc-merchant-happy.png`

Directional sprites (if needed):
- `spr_arrow-north.png`, `spr_arrow-east.png`, `spr_arrow-south.png`, `spr_arrow-west.png`

Or use a single sheet: `spr_arrow-all-dir.png` with Godot handling regions.

---

## Directory Structure for Assets

```
assets/
├── art/
│   ├── source/           # Native editor files (.kra, .psd, .ase) -- not imported
│   ├── export/           # Exported PNGs/JPGs ready for Godot import
│   │   ├── sprites/
│   │   ├── tiles/
│   │   ├── ui/
│   │   ├── backgrounds/
│   │   ├── portraits/
│   │   ├── icons/
│   │   └── fx/
│   └── reference/        # Mood boards, style guides, reference images
├── audio/
│   ├── source/           # Native project files (.aup, .flp) -- not imported
│   └── export/           # Final WAV/OGG ready for Godot
│       ├── sfx/
│       ├── music/
│       └── ambient/
└── fonts/                # Font files (.ttf, .otf)
    └── source/           # Font source/license files
```

**The `export/` folders are what Godot imports from.** Never edit files in `export/` -- edit in `source/` and export out. This keeps a clean pipeline.

---

## Godot Import Notes

- Godot auto-generates `.import/` files next to each asset. These should **not** be checked into Git.
- Use Godot's **import dock** to set:
  - Texture compression (lossless for sprites, compressed for backgrounds)
  - Mipmaps (off for pixel art, on for 3D textures)
  - Audio stream mode (samples for SFX under ~1 second, music for longer tracks)
  - Loop mode for OGG ambient tracks
- Re-importing: if an asset looks wrong in Godot, check the import settings before assuming the file is broken.

---

## Anti-Patterns to Avoid

| Bad | Why It's Bad | Fix |
|-----|-------------|-----|
| `final_final_v3_REAL.png` | Nobody knows which version is real. | `knight-idle-03.png` -- delete old versions |
| `Untitled-1.aec` | No context when someone sees this filename. | `music_menu-main.aup` |
| `Background.png` | Which background? Where? What state? | `bg_village-day.png` or `bg_village-night.png` |
| Mixing formats | Some PNGs, some JPGs, some BMPs for the same asset type. | Pick one format per use case and stick to it. |
| Storing source files mixed with exports | Godot tries to import everything. | Separate `source/` and `export/` directories. |
| Hardcoded paths in code that include `C:\Users\...` | Breaks on every other team member's machine. | Use relative paths only (`res://assets/...` in Godot). |

---

## Checklist for Every New Asset

- [ ] Filename follows the naming convention
- [ ] Asset is in the correct `assets/` subdirectory
- [ ] Source file saved in `source/`
- [ ] Exported to `export/` in the correct format
- [ ] Godot import settings are configured (compression, mipmaps, loop)
- [ ] Old versions deleted (if replacing)
- [ ] Asset referenced in the project tracker / spreadsheet (if tracking)
