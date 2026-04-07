---
type: entity
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/audio/audio-design.md
tags: [audio, assets, catalog, sound-effects, music-tracks]
---

# Audio Asset Catalog

## Overview

Inventory tracking for all audio assets in the game, including music tracks, sound effects, and voice/dialogue recordings.

## Music Track Inventory

| Asset | Context | Status | Format |
|-------|---------|--------|--------|
| Main Theme | Title screen | Not Started | OGG |
| Battle Music | Combat | Not Started | OGG |
| Exploration | Overworld/Travel | Not Started | OGG |
| Village/Town | Hub areas | Not Started | OGG |
| Victory/Defeat | Combat resolution | Not Started | OGG |

## SFX Inventory

| Asset | Category | Status | Format |
|-------|----------|--------|--------|
| Sword Swing | Combat | Not Started | OGG/WAV |
| Footstep (Grass) | Movement | Not Started | OGG/WAV |
| Footstep (Stone) | Movement | Not Started | OGG/WAV |
| UI Click | Interface | Not Started | OGG/WAV |
| Bird Ambient | Environment | Not Started | OGG/WAV |
| Wind | Environment | Not Started | OGG/WAV |

## Technical Format Standards

| Parameter | Value |
|-----------|-------|
| Sample Rate | 44.1 kHz |
| Bit Depth | 16-bit |
| Music Format | OGG (looping, compressed) |
| SFX Format | OGG for longer, WAV for short/one-shot |
| Voice Format | OGG |

## Storage Locations

- Music source: `assets/audio/music/`
- SFX source: `assets/audio/sfx/`
- Ambient source: `assets/audio/ambient/`
- Voice/dialogue: `assets/audio/voice/`

## See Also

- [[Sound Effects Design]]
- [[Music Design]]
- [[Audio Systems Design]]
