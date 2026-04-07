---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/audio/audio-design.md
  - docs/art/mood-board-reference.md
tags: [sfx, sound-design, game-audio, audio-effects]
---

# Sound Effects Design

## Overview

Sound Effects (SFX) design covers all non-musical, non-voice audio in the game, including combat feedback, movement, UI interactions, and environmental sounds.

## SFX Categories

| Category | Examples | Design Considerations |
|----------|----------|----------------------|
| **Combat** | Sword swing, hit impact, death | Weight and impact feel, realism vs stylized |
| **Movement** | Footstep on grass, footstep on stone | Surface-dependent variation, loop continuity |
| **Interface** | UI click, menu open/close | Subtle or pronounced, feedback clarity |
| **Environment** | Birds, wind, water, crowd | Layering density, spatial positioning |

## Required SFX Inventory

Initial SFX requirements include:

| SFX Name | Category | Purpose |
|----------|----------|---------|
| Sword Swing | Combat | Attack action feedback |
| Footstep (Grass) | Movement | Ground surface identification |
| Footstep (Stone) | Movement | Different ground surface |
| UI Click | Interface | Interaction confirmation |
| Bird Ambient | Environment | Environmental presence |
| Wind | Environment | Weather and atmosphere |

## Design Philosophy

Following the [[Audio Mood Board]] guidelines:

### Combat SFX
- Should have weight and impact
- Balance between realism and game-feel stylization
- Distinct sounds for different weapons or attack types

### Movement SFX
- Surface-dependent variation (grass, stone, wood, etc.)
- Consistent rhythm that matches animation timing
- Subtle enough not to cause audio fatigue

### UI SFX
- Immediate feedback for player actions
- Clear differentiation between different interaction types
- Volume should not compete with music or combat sounds

### Environmental SFX
- Layered for richness without muddiness
- Spatial positioning where applicable
- Volume should blend into the background

## Generation Methods

SFX can be created through:
- **AI Generation:** AudioCraft/AudioGen, ElevenLabs SFX, MyEdit
- **Community Libraries:** Freesound with AI-enhanced search
- **Field Recording:** Real-world foley capture
- **Synthesis:** Procedural audio generation in Godot

## Technical Implementation

- Format: OGG for compressed, WAV for shorter sounds
- Godot `AudioStreamPlayer` for one-shot effects
- Sound-specific volume controlled by SFX channel
- Consider object pooling for frequently played sounds

## See Also

- [[Audio Systems Design]]
- [[Music Design]]
- [[Audio Mood Board]]
- [[AI Audio Generation]]
