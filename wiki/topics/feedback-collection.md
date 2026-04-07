---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/qa/playtest-framework.md
  - docs/qa/testing-plan.md
  - docs/project/indie-game-dev-guide.md
tags:
  - qa
  - feedback
  - metrics
  - data-collection
---

# Feedback Collection

Methods and best practices for collecting, interpreting, and acting on player and tester feedback.

## Feedback Sources

### Playtest Feedback
- Structured feedback forms from [[Playtesting Framework|playtest sessions]]
- Observer notes during sessions
- Screen recordings for retrospective analysis

### Internal Feedback
- [[Team Structure|Team]] [[QA Strategy|smoke tests]] and weekly playtests
- Code review feedback on [[Sprint Planning|pull requests]]

### External Feedback
- Early builds on Itch.io for community feedback
- [[Steam Publishing|wishlist analytics]] (proxy for market interest)
- Post-launch [[Bug Tracking|user reports]] and reviews

## Quantitative Metrics

| Metric | What It Measures | Target |
|--------|-----------------|--------|
| Time to first action | Tutorial clarity | Under 30 seconds |
| Session length | Engagement | 15-30 minutes (matches core loop) |
| Completion rate | Pacing and difficulty | 60%+ of players complete |
| Death/restart frequency | Difficulty balance | Not frustratingly high |
| Feature usage | Design intent alignment | Core mechanics get most usage |
| FPS | Performance stability | Maintain target across tested hardware |
| Load times | Technical performance | Under 3 seconds |

## Qualitative Methods

### Feedback Form Design
- Keep it short (5 questions max) so people actually fill it out
- Use open-ended questions, not yes/no
- Ask "what was your goal?" not "did you like it?"
- Tailor specific questions to the mechanic being tested

### Observer Protocol
- Record where players get stuck and for how long
- Note timestamps for frustration and engagement moments
- Capture technical bugs and anomalies
- Document verbal feedback in real-time

### Think Aloud Protocol
- Ask players to narrate their thinking as they play
- "I'm looking for an inventory" "I think this button opens a map"
- Reveals mental models of the game interface

## Prioritization Framework

When processing collected feedback:
1. **Single report:** Note it, watch for patterns
2. **Two concurrent reports:** Investigate and gather more data
3. **Three or more concurrent reports:** Take action
4. **Unanimous positive feedback:** Identify and reinforce (do what works)

## Data Interpretation Guidelines

- Players are good at identifying problems, bad at suggesting solutions
- The problem described is real even when the suggested fix is wrong
- Positive feedback is as valuable as negative -- it tells you what to preserve
- Feedback from non-gamers is especially valuable for casual/educational games

## Community Feedback Integration

- Build dedicated [[Community Building|Discord server]] for feedback hub
- Post [[Playtesting Framework|devlog updates]] every 2-4 weeks on Itch.io
- Weekly Reddit threads in r/gamedev for broader feedback
- Offer early teacher preview builds for educational games

## See Also

- [[Playtesting Framework]]
- [[QA Strategy]]
- [[Bug Tracking]]
- [[Community Building]]
- [[Game Dev Marketing]]
