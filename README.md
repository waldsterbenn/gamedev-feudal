# Feudal

A feudal-themed game built from the ground up by first-time developers. The design follows the MDA framework (Mechanics, Dynamics, Aesthetics) and focuses on delivering a clear, playable vertical slice.

## Structure

```
docs/       ← Design, tech, art, audio, QA, and project documentation
src/        ← Game source code (Godot 4.x)
assets/     ← Textures, models, audio, fonts
config/     ← Build and engine configuration
build/      ← Compiled outputs (gitignored)
```

## Getting Started

1. Clone this repo
2. Read `docs/README.md` for workspace overview
3. Answer the design questionnaires in `docs/design/iq-game-design.md` to fill in the design doc
4. Use `docs/project/indie-game-dev-guide.md` as a facilitator walkthrough
5. Start with `docs/design/game-design.md` to capture your game concept

## Project Progress

### Phase 1: Foundation & Design (2026-04-05)

- [x] **Project structure initialized** — organized docs/, src/, assets/, config/ folders with README and gitignore
- [x] **Godot 4.x selected** — engine choice locked in technical spec, engine-specific gitignore added
- [x] **Game design document** — template created covering pillars, core loop, mechanics, UI, and controls
- [x] **Design questionnaires (IQ series)** — three interactive questionnaires covering game design (`iq-game-design.md`), lore/world-building (`iq-lore-world.md`), and game dev basics (`game-dev-basics.md`)
- [x] **Facilitator guides** — `iq-facilitator-guide.md` for running design sessions, plus a full `indie-game-dev-guide.md` walkthrough for first-time developers
- [x] **Technical spec** — engine settings architecture, resource management, performance targets (60 FPS / 256 MB), and build pipeline outlined
- [x] **Art & audio pipeline** — art style guide (`art-style-guide.md`), mood board reference (`mood-board-reference.md`), audio design document (`audio-design.md`), and asset naming conventions (`asset-naming-conventions.md`)
- [x] **QA framework** — playtest framework and testing plan with feedback loop methodology
- [x] **Project management** — design decisions log (`design-decisions.md`) and changelog established

### Phase 2: Vertical Slice (Planned)

- [ ] Define the core game concept through questionnaire responses
- [ ] Create first playable prototype in Godot 4.x
- [ ] Build placeholder art and audio assets
- [ ] Implement core gameplay loop
- [ ] Internal playtest round

### Phase 3: Polish & Release (Planned)

- [ ] Refine mechanics based on playtest feedback
- [ ] Finalize art and audio assets
- [ ] Menu, settings, and save system
- [ ] Distribution packaging
