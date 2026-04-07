---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/tech/ai-game-development-report.md
tags: [ai, music-generation, sound-effects, audio-generation, music-synthesis]
---

# AI Audio Generation

## Overview

AI audio generation tools cover three areas: music composition, sound effect generation, and audio mastering. These tools can significantly accelerate audio production for games.

## Music Generation

### Cloud-Based Services

| Tool | Strengths | Pricing |
|------|-----------|---------|
| **Suno** | Best-in-class generation with vocals, supports ambient/battle/tavern/epic themes | Free tier, $10/month |
| **Udio** | High audio quality, strong genre control, good for game OSTs | Free tier, $10/month |
| **Stable Audio** | Short clips and loops, good for ambient tracks | Free tier |

### Open-Source / Local

| Tool | Description | Run Environment |
|------|-------------|-----------------|
| **MusicGen** (AudioCraft) | Meta's open-source music generation, good for instrumental game music | HuggingFace, local |
| **Riffusion** | Music via spectrogram diffusion | Runs locally |

## Sound Effect Generation

| Tool | Type | Use Cases |
|------|------|-----------|
| **MyEdit Online SFX** | Web-based text-to-SFX | Quick prototyping, free tier |
| **AudioCraft / AudioGen** | Open-source text-to-SFX | Footsteps, combat, ambient, UI clicks |
| **ElevenLabs SFX** | Commercial SFX generation | High quality, paid plans |
| **Freesound + AI Tagging** | Community SFX library | AI-enhanced search, free |

## Music and Audio Mastering

| Tool | Purpose | Cost |
|------|---------|------|
| **LANDR** | AI mastering for release-quality polish | Paid |
| **Auphonic** | AI post-production: leveling, noise reduction, loudness | Free tier |

## Production Pipeline

For gamedev-feudal, the recommended audio pipeline:
1. **Draft:** Music via Suno or MusicGen, SFX via AudioGen
2. **Refine:** Post-processing with Auphonic for leveling and noise reduction
3. **Master:** LANDR for final polish before integration
4. **Integrate:** Import into Godot via [[Audio Systems Design]] pipeline

## Important Considerations

### Licensing

- **Suno/Udio:** Paid tiers typically grant commercial rights; free tiers may not
- Check Terms of Service before using generated audio commercially
- Ensure generated content complies with project [[Audio Design]] specifications

### Format Compatibility

- Godot supports OGG and WAV formats natively
- Target sample rate: 44.1 kHz, 16-bit depth
- Looping background music should be seamless

## See Also

- [[AI in Game Development]]
- [[Audio Systems Design]]
- [[Text-to-Speech Technologies]]
- [[AI Game Development Budget Options]]
- [[MusicGen]]
