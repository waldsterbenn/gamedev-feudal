# Feudal - Game Development Workspace

> **Project:** Feudal
> **Founded:** 2026-04-05
> **Status:** Pre-Production

## Workspace Structure

```
gamedev-feudal/
├── docs/
│   ├── design/
│   │   ├── game-design.md           # Core game design document
│   │   ├── world-lore.md            # World building and lore bible
│   │   ├── level-design.md          # Level layouts and area documentation
│   │   ├── game-dev-basics.md       # Plain-language game dev intro for newcomers
│   │   ├── iq-game-design.md        # Game design interview questionnaire
│   │   ├── iq-lore-world.md         # Lore & world interview questionnaire
│   │   └── iq-facilitator-guide.md  # How to run design interview sessions
│   ├── tech/
│   │   └── technical-spec.md        # Engine, architecture, and tech specs (Godot 4.x)
│   ├── art/
│   │   ├── art-style-guide.md       # Visual style and art guidelines
│   │   └── mood-board-reference.md  # Visual & audio reference collection / mood board
│   ├── audio/
│   │   └── audio-design.md          # Music, SFX, and audio specs
│   ├── qa/
│   │   ├── testing-plan.md          # QA strategy and bug tracking
│   │   └── playtest-framework.md    # Playtest process, feedback forms, metrics
│   └── project/
│       ├── project-plan.md          # Milestones, team, and sprint planning
│       ├── changelog.md             # Project change history
│       ├── design-decisions.md      # Architecture Decision Records (ADRs)
│       └── asset-naming-conventions.md  # File naming, formats, and directory rules
├── src/          # Godot project root (create when ready)
├── assets/       # Source assets (create when ready)
├── config/       # Config files (create when ready)
└── build/        # Build outputs (gitignored)
```

## Quick Start

1. **Read the basics** -- Start with `docs/design/game-dev-basics.md` if you're new to game dev
2. **Run interviews** -- Use `docs/design/iq-game-design.md` and `iq-lore-world.md` to define the game
3. **Track decisions** -- Record every major choice in `docs/project/design-decisions.md`
4. **Set art direction** -- Populate `docs/art/mood-board-reference.md` before any art is made
5. **Follow conventions** -- Read `docs/project/asset-naming-conventions.md` before adding files
6. **Plan playtests** -- Follow `docs/qa/playtest-framework.md` from the first playable build

## Conventions

- All documentation uses Markdown (`.md`)
- One document per concept (keep files focused)
- Status tags: `Draft` / `In Review` / `Approved` / `Archived`
- Tables use pipe syntax with header separators
- All decisions go through the ADR process in `design-decisions.md`
