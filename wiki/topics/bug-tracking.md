---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/qa/testing-plan.md
tags:
  - qa
  - bug-tracking
  - issue-management
---

# Bug Tracking

Process for tracking, categorizing, and resolving defects throughout the development lifecycle.

## Bug Tracker

- **Tracker:** GitHub Issues / Jira / Other (to be selected)
- Issues should be linked to [[QA Strategy|test results]] and [[Sprint Planning|sprint items]]

## Priority Levels

| Priority | Level | Description | Example |
|----------|-------|-------------|---------|
| **P0** | Critical | Game-breaking, blocks release | Crash on startup, soft lock, data corruption |
| **P1** | High | Major feature broken, workaround exists | Combat mechanic fails, save doesn't work |
| **P2** | Medium | Minor bug, affects polish | UI overlap, animation glitch |
| **P3** | Low | Cosmetic issues, typos, edge cases | Text typo, rare visual artifact |

## Bug Lifecycle

1. **Discovered** -- Found during testing, [[QA Strategy|smoke test]], [[Playtesting Framework|playtest]], or community feedback
2. **Reported** -- Logged in tracker with reproducible steps, build version, severity assessment
3. **Triage** -- Assigned priority (P0-P3) and owner
4. **In Progress** -- Developer working on fix
5. **Fixed** -- Implemented and committed
6. **Verified** -- [[QA Strategy|Regression test]] confirms fix
7. **Closed** -- Bug resolved and verified

## Known Issues Log

Maintain a living table of known issues:

| ID | Description | Priority | Status |
|----|-------------|----------|--------|
| - | - | - | - |

## Bug Tracking Per Testing Phase

| Test Type | Bug Focus |
|-----------|-----------|
| Smoke Test | P0 critical issues only |
| Regression | All previously fixed [[QA Strategy|verified bugs]] |
| Performance | P1/P2 performance-related issues |
| Compatibility | P0/P1 platform-specific issues |

## Best Practices

- Always include build version in bug reports
- Attach screenshots or recordings when possible
- Use consistent naming for issue titles
- Link related issues to enable clustering
- Resolve P0 before [[Development Milestones|alpha]] milestone
- Resolve P0/P1 before [[Development Milestones|release candidate]]

## See Also

- [[QA Strategy]]
- [[Playtesting Framework]]
- [[Sprint Planning]]
- [[Development Milestones]]
