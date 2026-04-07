---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/project/design-decisions.md
tags:
  - architecture
  - ADR
  - decision-log
---

# Design Decisions

This page captures the Architecture Decision Records (ADRs) for the project. Every significant design and technical choice is documented with context, decision, consequences, and alternatives considered.

## ADR Process

### How to Use This Log

When the team makes a decision (chooses a technology, picks a camera perspective, commits to a combat style):

1. Create a new entry with the next number
2. Write the decision, the context (why), and the consequences (what it means)
3. List alternatives that were considered but rejected
4. Link to any supporting documents (questionnaire answers, prototypes, research)

**Do not** use this for minor details (button colors, variable names). Use it for design and technical choices that would be expensive to reverse later.

### ADR Format

### ADR-NNN: Short Title

- **Date:** YYYY-MM-DD
- **Status:** Proposed | Accepted | Deprecated | Superseded
- **Category:** Engine | Design | Art | Audio | Technical | Process

**Context:** What prompted this decision? What problem are we solving?

**Decision:** What did we decide?

**Consequences:** What does this mean for the project? What does it lock us into or out of?

**Alternatives Considered:** What else did we look at, and why was it rejected?

**References:** Links to related docs, prototypes, or discussions.

## Active Decisions

### ADR-001: Use Godot 4.x as the Game Engine

- **Date:** 2026-04-05
- **Status:** Accepted
- **Category:** Engine

**Context:** Need a game engine for a feudal-themed game. Team includes first-time developers. Requirements: free/open source, gentle learning curve, good 2D support, no licensing complication.

**Decision:** Use Godot 4.x with GDScript as the primary scripting language. GDExtension with C++ available if performance requires it.

**Consequences:**
- Engine is free with no royalties ever
- GDScript is easier for beginners than C# or C++
- Smaller community than Unity/Unreal, so fewer third-party tutorials -- but growing fast
- Godot's node/scene model requires learning its architecture (but it's intuitive once understood)
- Export targets: Windows, Linux, macOS supported. WebGL and console ports less mature.

**Alternatives Considered:**
- Unity -- larger ecosystem, but C# steeper learning curve, licensing changes introduced uncertainty, heavier footprint
- Unreal -- powerful but overkill for this scope, C++ is significant learning curve, project sizes are large from the start

### ADR-002: Use Markdown for All Project Documentation

- **Date:** 2026-04-05
- **Status:** Accepted
- **Category:** Process

**Context:** Need a documentation system accessible to all team members, version-controllable, and easy to edit without special software.

**Decision:** All project documentation is written in Markdown (.md) and stored in the `docs/` directory.

**Consequences:**
- Docs are in Git -- version history, diffs, and branch-specific versions for free
- Readable in any text editor, GitHub, or Markdown viewer
- No special tools needed to write docs
- Not suitable for complex visual diagrams -- use Excalidraw files or image references

**Alternatives Considered:**
- Google Docs / Notion -- easier collaboration, but not version-controlled and not alongside code
- Wiki (GitHub Wiki) -- version controlled but harder to manage alongside the main repo

## Decision Categories

Decisions fall into these categories:
- **Engine** -- Technology and tooling choices
- **Design** -- Gameplay, UX, and creative decisions
- **Art** -- Visual style and pipeline decisions
- **Audio** -- Sound design and music choices
- **Technical** -- Architecture and implementation decisions
- **Process** -- Workflow, documentation, and team process decisions

## See Also

- [[Technical Choices]]
- [[Documentation Standards]]
- [[Project Structure]]
- [[Development Milestones]]
