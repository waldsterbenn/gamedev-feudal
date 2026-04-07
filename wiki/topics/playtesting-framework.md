---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/qa/playtest-framework.md
tags:
  - qa
  - playtesting
  - feedback
  - user-testing
---

# Playtesting Framework

A systematic approach to testing the game, collecting feedback from real players, and turning observations into concrete design actions.

## Why Playtesting Matters

You designed the game. You know every mechanic, every shortcut. **You cannot play your own game like a real player.** Every minute watching someone struggle with something you thought was obvious is worth an hour of design debate.

## Types of Playtests

### 1. Gut Check (Internal)
- **Who:** [[Team Structure|Team members]]
- **When:** Any time something new is built
- **Goal:** "Does this work at all?" -- finding broken mechanics and obvious design flaws
- **Format:** Sit together, take notes, talk through issues in real time

### 2. Closed Playtest (Trusted Outsiders)
- **Who:** Friends, family, gamers not on the team
- **When:** Stable [[Development Milestones|vertical slice]] or demo build
- **Goal:** "Does this make sense to someone who didn't build it?" -- confusion points, UX problems
- **Format:** Give the build, hand them a feedback form, watch without helping

### 3. Blind Playtest (Target Audience)
- **Who:** Target audience with no prior knowledge of the game
- **When:** Polished slice or near-complete build
- **Goal:** "Is this fun for the player it's designed for?" -- real test of design choices
- **Format:** Minimal instructions, no help, structured feedback collection

## Playtest Session Process

### Before the Session
1. Define what you are testing -- be specific, not vague
2. Prepare a build that isolates the thing being tested
3. Write a feedback form (see below)
4. Set up recording (screen capture or webcam)

### During the Session
1. Give minimal instructions -- only what a store download would provide
2. **Do not help** -- this is the hardest and most important rule
3. Think aloud protocol -- ask player to narrate their thinking
4. Watch their face and hands -- frustration, confusion, boredom
5. Take notes, don't argue

### After the Session
1. Debrief immediately -- document confusion points, stuck moments, enjoyment
2. **Prioritize issues** using the 1-2-3 rule:
   - If one player reports something: note it
   - If two players report the same thing: investigate it
   - If three or more report the same thing: fix it
3. Update your [[Sprint Planning|task tracker]] with concrete action items

## Feedback Form Template

```
FEEDBACK FORM - [Game Name] - [Date] - [Build Version]

1. What were you trying to do in the game? (What was your goal?)
2. What was the most confusing part?
3. What was the most fun part?
4. On a scale of 1-10, how satisfying was [specific mechanic]?
5. If you could change one thing about the game, what would it be?
```

Observer notes: where player got stuck, frustration moments, engagement moments, technical issues.

## Metrics to Track

| Metric | How to Measure | What It Tells You |
|--------|---------------|-------------------|
| Time to first action | Start to first meaningful input | Tutorial clarity |
| Death/restart frequency | Per session or per minute | Difficulty balance |
| Session length | Start to quit | Engagement/retention |
| Completion rate | % who finish | Pacing and motivation |
| Feature usage | Mechanics used vs. ignored | Design alignment |

## Playtest Cadence by Phase

| [[Development Milestones|Phase]] | Frequency | Focus |
|--------------|-------------------|-------|
| Greybox / Prototype | Weekly (gut check) | Core mechanics, does the loop work |
| Vertical slice | Bi-weekly (closed) | Full experience, UX, difficulty |
| Feature-complete | Monthly (blind) | Overall fun, pacing, polish gaps |
| Pre-release | As needed (blind) | Bugs, onboarding, first impressions |

## Version Tracking for Builds

Every playtest build should be versioned:

```
Build: 0.1 - Combat Prototype
Date: YYYY-MM-DD
Known issues: No hit feedback, enemy AI is basic
What to test: Does combat feel good?
```

## Common Playtest Mistakes

| Mistake | Why It's Bad | Fix |
|---------|-------------|-----|
| Helping the player | Masks design flaws | Shut up and let them struggle |
| Testing your own work immediately | Not the target audience | Have someone else test, or wait a day |
| Leading questions ("Did you like combat?") | Gets polite no/yes, not honest feedback | Ask open questions |
| Too much feedback from one person | One opinion isn't data | Get at least 3 players minimum |
| Defending your design | Player won't give honest feedback | Thank them, note it, don't explain |
| Ignoring positive feedback | Need to know what WORKS too | Note what players love and double down |
| Treating all feedback as gospel | Players identify problems, propose bad solutions | Listen to the problem. Their solution might be wrong. |

## Expect to Kill 30-50% of Early Features

This is normal and saves months of wasted work. Players will not interact with your game the way you designed. That is data, not failure.

## See Also

- [[QA Strategy]]
- [[Bug Tracking]]
- [[Feedback Collection]]
- [[Sprint Planning]]
- [[Ethical Design]]
