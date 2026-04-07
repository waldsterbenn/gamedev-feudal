---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/qa/testing-plan.md
  - docs/project/indie-game-dev-guide.md
tags:
  - qa
  - testing
  - quality-assurance
---

# QA Strategy

A comprehensive testing strategy covering multiple testing tiers from unit tests to compatibility testing.

## Testing Strategy Overview

### Unit Testing
- Test individual functions and systems in isolation
- Framework and coverage targets to be defined for [[Technical Choices|Godot]] environment

### Integration Testing
- Test interactions between game systems
- Focus on data flow between modules

## Build Testing Matrix

| Test Type | Frequency | Who | Notes |
|-----------|-----------|-----|-------|
| Smoke Test | Every build | Dev | Core functionality check |
| Regression | Before release | QA | All known [[Bug Tracking|bug fixes]] verified |
| Performance | Weekly | Dev | FPS, memory, load times |
| Compatibility | Monthly | QA | Different hardware/OS testing |

## QA Checklist

### Core Gameplay
- [ ] Player movement feels responsive
- [ ] Combat works as designed
- [ ] Inventory system functional
- [ ] Progression saves correctly

### UI
- [ ] All buttons functional
- [ ] Text fits in containers
- [ ] Menus navigate correctly
- [ ] Settings apply correctly

### Performance
- [ ] Target FPS maintained
- [ ] No memory leaks detected
- [ ] Load times within target
- [ ] No crashes after extended play

## Playtest Integration

QA integrates with the [[Playtesting Framework]] at multiple points:

- **Week 3-4** with a greybox of the core loop -- test whether the game is fun
- **Weekly internal playtests** with the team
- **Bi-weekly external tests** with friends and target audience

## Known Issues Tracking

Maintain a table of known issues with IDs, descriptions, priorities, and statuses. Use the [[Bug Tracking|priority system]] to categorize and sequence fixes.

## Quality Standards Per Milestone

| Milestone | QA Focus |
|-----------|----------|
| Vertical Slice | Core loop fun, stability, basic UI |
| Alpha | All features functional, placeholder acceptable |
| Beta | Full content polish, no crashes, target FPS |
| Release Candidate | Edge cases, all [[Bug Tracking|P0/P1 issues]] resolved |
| Launch | Day 1 patch readiness, [[Steam Publishing|build validation]] |

## See Also

- [[Bug Tracking]]
- [[Playtesting Framework]]
- [[Development Milestones]]
- [[Sprint Planning]]
