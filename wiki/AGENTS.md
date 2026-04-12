# LLM Wiki Schema

> **Purpose:** Guide the LLM agent on how to build, maintain, and query the persistent wiki for the Feudal game project.
> **Status:** Draft
> **Last Updated:** 2026-04-07

## Overview

This wiki sits alongside the existing `docs/` folder. They serve different purposes:

| Layer | What it is | Who owns it | How it relates |
|---|---|---|---|
| `docs/` | Project documentation -- game design, tech specs, plans, ADRs, research reports | Human-driven | Stable, curated project artifacts |
| `wiki/` (this folder) | Full game knowledge base -- design knowledge, lore, narrative, scripts, dialogs, cross-references | LLM + Human co-authored | Central source of truth for game content |
| `wiki/raw/` | Immutable source documents fed into the wiki | Human-curated | Raw materials the LLM reads but never modifies |

The wiki is a **compounding knowledge layer**. It reads from `docs/` and `wiki/raw/`, synthesizes, cross-references, and keeps everything current. It never modifies files in `docs/` or `wiki/raw/`.

## Directory Structure

```
wiki/
├── AGENTS.md           # This file -- the schema
├── index.md            # Catalog of all wiki pages with summaries
├── log.md              # Append-only chronological activity log
├── raw/                # Immutable source documents
│   └── _README.md      # How to add sources
├── topics/             # Topic/concept pages (e.g., Feudalism, Manorialism)
├── entities/           # Entity pages (characters, factions, places, historical figures)
├── synthesis/          # Synthesis pages -- comparisons, analyses, evolving theses
└── queries/            # Answers to user questions that are worth preserving
```

## Conventions

### Page Format
Every wiki page uses this frontmatter:

```yaml
---
type: topic | entity | synthesis | query
created: 2026-04-07
updated: 2026-04-07
sources: ["raw/source-file.md"]
tags: [tag1, tag2]
---
```

Follow with the page content. Always end with a `## See Also` section containing `[[wikilinks]]` to related pages.

### Cross-References
Use `[[wikilinks]]` (Obsidian-style) throughout. These enable graph view and manual search.

### Status Tags
- **Draft** -- Page is new or in development
- **In Review** -- Ready for human check
- **Stable** -- Verified, good to rely on
- **Contradicted** -- Newer sources challenge claims on this page; see notes

### Contradictions
When a new source contradicts existing wiki content:
1. Note the contradiction on both pages involved
2. Update the affected page's `## Contradictions` section
3. Flag the status as "Contradicted"
4. Explain what changed and why

## Workflows

### Ingest a source
1. Read the source from `wiki/raw/` or `docs/` (if ingesting an existing doc)
2. Identify key concepts, entities, claims, and relationships
3. Create or update pages in `topics/` and `entities/`
4. Update `index.md` with new/changed entries
5. Append an entry to `log.md` with format:
   `## [YYYY-MM-DD] ingest | Source Title`
6. Check for contradictions with existing wiki content
7. Report a summary of changes made

### Query the wiki
1. Read `index.md` to find relevant pages
2. Read the relevant pages
3. Synthesize an answer with citations (link to wiki pages)
4. If the answer is substantively valuable, save it as a new page in `queries/`
5. Append an entry to `log.md`:
   `## [YYYY-MM-DD] query | Question Summary`

### Lint (health check)
1. Scan all pages for:
   - Contradictions between pages
   - Stale claims superseded by newer sources
   - Orphan pages (no inbound links from other wiki pages)
   - Concepts mentioned but lacking their own page
   - Missing cross-references in `## See Also` sections
   - Pages that could benefit from new source material
2. Report findings with specific recommendations
3. Append an entry to `log.md`:
   `## [YYYY-MM-DD] lint | Issues Found: N`

## Index Maintenance
The `index.md` file is the primary navigation structure. It should be updated on every ingest. Format:

```markdown
# Wiki Index

*Auto-maintained by the LLM agent. Updated on every ingest.*

## Topics
- [[Page Name]] -- One-line summary. (Updated: YYYY-MM-DD)

## Entities
- [[Entity Name]] -- One-line summary. (Updated: YYYY-MM-DD)

## Synthesis
- [[Synthesis Title]] -- One-line summary. (Updated: YYYY-MM-DD)

## Queries
- [[Query Title]] -- One-line summary. (Updated: YYYY-MM-DD)
```

## Log Maintenance
The `log.md` is append-only. New entries go at the top. Format:

```markdown
# Wiki Log

*Append-only. Newest entries at top.*

## [2026-04-07] ingest | Feudal System Deep Research Report
- Processed: raw/feudal-system.md
- Created: 12 pages (8 topics, 3 entities, 1 synthesis)
- Updated: 4 existing pages
- Contradictions: 0
```

## Important Rules

1. **Never modify** files in `docs/` or `wiki/raw/`
2. **Always update** `index.md` when creating/modifying pages
3. **Always append** to `log.md` after any wiki operation
4. **Always include** `## See Also` with wikilinks on every page
5. **Always check** for contradictions when adding new information
6. **File valuable outputs** back into the wiki as `queries/` pages
7. **Use frontmatter** consistently on every page
