---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/project/asset-naming-conventions.md
tags:
  - assets
  - naming
  - conventions
  - pipeline
---

# Asset Naming Conventions

Standardized naming and organization conventions for all art, audio, and imported assets in the project.

## Core Rules

1. **Lowercase only.** No spaces. No special characters except hyphens and underscores.
2. **Use hyphens to separate logical groups** and **underscores to separate modifiers**. Example: `bg_forest-tileset_01.png`
3. **Prefix by asset type** for file browser grouping.
4. **Version with numbers** at the end (`01`, `02`, `03`). Delete old versions immediately.
5. **Be specific but not verbose.** `spr_player-run` is clear. `spr_player-character-running-animation-v2` is not.

## Asset Prefixes

### Sprites / 2D Art

| Prefix | Meaning | Examples |
|--------|---------|---------|
| `spr_` | General sprite | `spr_knight-idle`, `spr_castle-exterior` |
| `tile_` | Tilemap tile | `tile_grass-01`, `tile_wall-corner` |
| `bg_` | Background | `bg_village-day`, `bg_throne-room` |
| `ui_` | UI element | `ui_button-normal`, `ui_health-frame` |
| `fx_` | Effect / particle sprite | `fx_blood-spatter`, `fx_dust-cloud` |
| `portrait_` | NPC / character portrait | `portrait_lord-edric` |
| `icon_` | Small icon | `icon_gold`, `icon_sword-iron` |

### Audio

| Prefix | Meaning | Examples |
|--------|---------|---------|
| `sfx_` | Sound effect | `sfx_sword-swing`, `sfx_coin-collect` |
| `sfx-ui_` | UI feedback sound | `sfx-ui_click`, `sfx-ui_confirm` |
| `sfx-foley_` | Footsteps, cloth | `sfx-foley_leather-step` |
| `amb_` | Ambient / looping | `amb_forest-wind`, `amb_rain-heavy` |
| `music_` | Background music | `music_menu-main`, `music_battle-intense` |

## Format Standards

| Use Case | Format | Notes |
|----------|--------|-------|
| Sprites / tiles / UI | **PNG** | Lossless, transparency support |
| Backgrounds (no transparency) | **JPG** (80-90% quality) | Smaller file size |
| SFX / Foley | **WAV** (44.1kHz, 16/24-bit) | High quality source |
| Music / Ambient loops | **OGG Vorbis** | Godot handles streaming efficiently |
| Cutscenes | **WebM** (VP9 codec) | Native Godot support |
| Source files | **Native** (.kra, .psd, .aseprite) | Keep in `source/` -- not imported |

## Directory Structure

```
assets/
├── art/
│   ├── source/           # Native editor files -- not imported
│   ├── export/           # Exported PNGs/JPGs for Godot
│   └── reference/        # Mood boards, style guides
├── audio/
│   ├── source/           # Native project files -- not imported
│   └── export/           # Final WAV/OGG for Godot
└── fonts/                # Font files (.ttf, .otf)
```

The `export/` folders are what Godot imports from. Never edit files in `export/` -- edit in `source/` and export out.

## Animation Naming

Frame-by-frame or sprite-sheet animations:
```
spr_{character}-{animation}-{frame-number}.png
```
Examples: `spr_knight-idle-01.png`, `spr_knight-attack-06.png`

Sprite sheets (single image):
```
spr_{character}-{animation}.png
```

## Common Anti-Patterns

| Bad | Why It's Bad | Fix |
|-----|-------------|-----|
| `final_final_v3_REAL.png` | No way to know real version | `knight-idle-03.png` -- delete old |
| `Untitled-1.aec` | No context | `music_menu-main.aup` |
| `Background.png` | No specificity | `bg_village-day.png` |
| Mixing formats | Inconsistent pipeline | Pick one format per use case |
| Source files mixed with exports | Godot imports everything | Separate `source/` and `export/` |

## Godot Import Notes

- Auto-generated `.import/` files should **not** be in Git
- Set texture compression, mipmaps (off for pixel art), audio stream mode in import dock
- Use audio buses for compression/reverb, not per-file effects

## See Also

- [[Project Structure & Git]]
- [[Technical Choices]]
- [[Art & Audio Pipeline]]
- [[Documentation Standards]]
