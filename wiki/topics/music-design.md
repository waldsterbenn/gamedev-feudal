---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/audio/audio-design.md
tags: [music, bgm, game-music, soundtrack, music-composition]
---

# Music Design

## Overview

Music design covers all background music (BGM) tracks for the game, defining the tracks needed, their context, mood, and production status.

## Required Music Tracks

| Track | Context | Mood | Notes |
|-------|---------|------|-------|
| **Main Theme** | Title screen | Epic, atmospheric | Should establish the game's musical identity |
| **Battle Music** | Combat encounters | Intense, driving | Dynamic intensity based on combat situation |
| **Exploration** | Overworld / travel | Atmospheric, calm | Supports exploration without fatigue |
| **Village / Town** | Hub areas | Warm, lively | Reflects civilian life and activity |
| **Victory / Defeat** | Combat resolution | Triumphant or somber | Short stings, not full tracks |

## Musical Style

Music style should be determined in consultation with the [[Audio Mood Board]], considering:

- **Instrumentation** -- medieval folk (lute, hurdy-gurdy) vs cinematic orchestral vs hybrid
- **Tempo** -- varies by context (slow for exploration, fast for combat)
- **Production style** -- authentic period feel vs modern polished production

## AI-Assisted Music Generation

Several AI tools can assist in music creation (see [[AI Audio Generation]]):
- **Suno** -- full song generation including vocals
- **MusicGen (AudioCraft)** -- open-source instrumental music generation
- **Stable Audio** -- shorter loops and ambient tracks
- **Riffusion** -- spectrogram-based music generation

## Integration with Godot

Music is implemented via `AudioStreamPlayer` nodes:
- Set to loop for continuous background playback
- Fade in/out during scene transitions
- Volume controlled by the Music channel in [[Audio Systems Design]]

## Production Pipeline

1. **Draft:** Generate initial tracks via AI tools or composition
2. **Review:** Check against [[Audio Mood Board]] references
3. **Master:** Apply LANDR or Auphonic for polish
4. **Integrate:** Import as OGG into Godot, assign to AudioStreamPlayer

## See Also

- [[Audio Systems Design]]
- [[Sound Effects Design]]
- [[Audio Mood Board]]
- [[AI Audio Generation]]
