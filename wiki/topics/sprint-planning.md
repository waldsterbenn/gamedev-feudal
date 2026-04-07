---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/project/project-plan.md
  - docs/project/indie-game-dev-guide.md
tags:
  - project-management
  - agile
  - sprints
---

# Sprint Planning

Sprint planning for game development follows a hybrid approach that adapts traditional Agile practices for the iterative nature of game design.

## Sprint Structure Template

# Sprint N - YYYY-MM-DD

### Goals
- Goal 1

### Tasks
- [ ] Task 1
- [ ] Task 2

Current sprint definitions are marked as TODO -- sprint cadence needs to be established.

## Hybrid Agile for Game Dev

Traditional Agile does not work exactly the same way for game development. Requirements emerge from [[Playtesting Framework|playtests]], not from upfront design.

**Recommended hybrid approach:**
- Use **Agile/kanban** for asset pipeline, [[Bug Tracking|bug tracking]], and audio integration
- Use **iterative, time-boxed prototyping sprints** for game design
- Write a **dynamic 1-page Game Design Document (GDD)**
- Update the GDD only after code proves a mechanic is fun

## Sprint Guidelines

### Asset Pipeline & Bug Tracking (Agile-friendly)
- These work well with traditional sprint planning
- Tasks are well-defined and testable
- Can be estimated with reasonable accuracy

### Game Design (Prototype-friendly)
- Time-boxed exploration (1-2 week cycles)
- Goals are discovery-oriented, not completion-oriented
- Accept that mechanics may be discarded after testing
- [[Risk Log|Scope creep]] is the primary risk to manage

## Risk Log

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Scope creep | Medium | High | Strict sprint boundaries |

## Sprint Best Practices

- Ship one small playable piece per sprint
- Define clear sprint goals that align with [[Development Milestones|current milestone]]
- Separate sprint planning from design exploration
- Use strict sprint boundaries to prevent [[Risk Log|scope creep]]

## Dependencies

List external or internal dependencies:

| Dependency | Needed By | Status |
|-----------|-----------|--------|
| Engine setup | All | Done |

## See Also

- [[Development Milestones]]
- [[Team Structure]]
- [[Risk Log]]
- [[Playtesting Framework]]
- [[Bug Tracking]]
