# Feudal - Game Development Workspace

> **Project:** Feudal
> **Founded:** 2026-04-05
> **Status:** Pre-Production

## Workspace Structure

```
gamedev-feudal/
├── docs/          # Project documentation (human-curated, stable artifacts)
│   ├── design/    # Game design documents, questionnaires, world lore
│   ├── tech/      # Engine, architecture, and technical specs
│   ├── art/       # Visual style guide, mood board
│   ├── audio/     # Music, SFX, and audio design
│   ├── qa/        # Testing plans, playtest frameworks
│   └── project/   # Plans, changelog, ADRs, conventions
├── wiki/          # LLM-maintained knowledge base (compounding, cross-referenced)
│   ├── AGENTS.md  # Schema -- tells LLM how to maintain the wiki
│   ├── index.md   # Catalog of all wiki pages
│   ├── log.md     # Append-only activity log
│   ├── raw/       # Immutable source documents for ingestion
│   ├── topics/    # Concept pages (mechanics, systems, design patterns)
│   ├── entities/  # Entity pages (characters, factions, locations)
│   ├── synthesis/ # Analyses, comparisons, evolving theses
│   ├── queries/   # Preserved Q&A and analysis outputs
│   ├── lore/      # Game lore and worldbuilding
│   ├── narrative/ # Story arcs, plot outlines, narrative structure
│   ├── scripts/   # Cutscene scripts, event scripts
│   └── dialogs/   # NPC dialogs, quest conversations
├── src/           # Godot project root (create when ready)
├── assets/        # Source assets (create when ready)
├── config/        # Config files (create when ready)
└── build/         # Build outputs (gitignored)
```

## Quick Start

1. **Read the basics** -- Start with `docs/design/game-dev-basics.md` if you're new to game dev
2. **Run interviews** -- Use `docs/design/iq-game-design.md` and `iq-lore-world.md` to define the game
3. **Track decisions** -- Record every major choice in `docs/project/design-decisions.md`
4. **Set art direction** -- Populate `docs/art/mood-board-reference.md` before any art is made
5. **Follow conventions** -- Read `docs/project/asset-naming-conventions.md` before adding files
6. **Plan playtests** -- Follow `docs/qa/playtest-framework.md` from the first playable build

## LLM Wiki

The `wiki/` folder is a persistent, LLM-maintained knowledge base that complements the human-curated `docs/`. See `wiki/AGENTS.md` for the full schema.

| What | Where | Purpose |
|---|---|---|
| Design docs | `docs/` | Stable project artifacts (GDD, specs, ADRs) |
| Knowledge base | `wiki/topics/` | Concepts, mechanics, design patterns |
| Entities | `wiki/entities/` | Characters, factions, locations |
| Lore | `wiki/lore/` | Worldbuilding, history, cultures |
| Narrative | `wiki/narrative/` | Story arcs, plot outlines |
| Dialogs/Scripts | `wiki/dialogs/` + `wiki/scripts/` | NPC conversations, cutscenes |
| Sources | `wiki/raw/` | Documents to ingest into the wiki |

The LLM reads from `docs/` and `wiki/raw/`, synthesizes knowledge, maintains cross-references, and keeps everything current. You direct; it maintains.

## Conventions

- All documentation uses Markdown (`.md`)
- One document per concept (keep files focused)
- Status tags: `Draft` / `In Review` / `Approved` / `Archived`
- Tables use pipe syntax with header separators
- All decisions go through the ADR process in `design-decisions.md`
