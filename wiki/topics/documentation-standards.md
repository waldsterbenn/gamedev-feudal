---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/project/design-decisions.md
  - docs/qa/testing-plan.md
  - docs/project/asset-naming-conventions.md
tags:
  - documentation
  - standards
  - markdown
---

# Documentation Standards

All project documentation follows a unified standard using Markdown format, stored in the `docs/` directory alongside the codebase.

## Markdown for All Documentation

**Status:** Accepted (ADR-002)

All project documentation is written in Markdown (.md) and stored in the `docs/` directory.

### Benefits
- Docs are in Git -- version history, diffs, and branch-specific versions
- Readable in any text editor, GitHub, or Markdown viewer
- No special tools needed to write docs
- Version-controlled alongside [[Technical Choices|code]]

### Limitations
- Not suitable for complex visual diagrams -- use Excalidraw files or image references
- Cannot embed interactive content

## Wiki Architecture

This wiki uses Obsidian-style formatting:
- YAML frontmatter on every page (type, created, updated, sources, tags)
- [[wikilinks]] for internal page references
- `## See Also` section at the bottom of each page for related topics

## Documentation Categories

| Category | Directory | Examples |
|----------|-----------|---------|
| Project Management | `docs/project/` | [[Development Milestones]], [[Sprint Planning]] |
| Design & Technical | `docs/design/`, `docs/tech/` | [[Design Decisions]], technical specs |
| QA & Testing | `docs/qa/` | [[QA Strategy]], [[Playtesting Framework]] |
| Wiki Topics | `wiki/topics/` | Synthesized knowledge pages |
| Wiki Synthesis | `wiki/synthesis/` | Cross-document analysis |

## Documentation Best Practices

- Every document should have a status header (Status, Created, Last Updated)
- Use tables for structured data (milestones, risk logs, [[Bug Tracking|known issues]])
- Include checklists for actionable items
- Reference related documents using wiki-style links

## See Also

- [[Design Decisions]]
- [[Technical Choices]]
- [[Asset Naming Conventions]]
- [[Project History]]
