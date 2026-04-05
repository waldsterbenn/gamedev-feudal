# Playtesting Framework

> **Purpose:** Systematic approach to testing the game, collecting feedback, and turning observations into action.
> **Rule:** Playtesting starts the moment you have something playable -- even if it's a greybox with two mechanics.

---

## Why Playtesting Matters

You designed the game. You know every mechanic, every shortcut, every intended path. **You cannot play your own game like a real player.**

Every minute you spend watching someone struggle with something you thought was obvious is worth an hour of debate in a design meeting.

---

## Types of Playtests

### 1. Gut Check (Internal)
- **Who:** Team members
- **When:** Any time something new is built
- **Goal:** "Does this work at all?" -- finding broken mechanics, crashes, obvious design flaws
- **Format:** Sit together, take notes, talk through issues in real time

### 2. Closed Playtest (Trusted Outsiders)
- **Who:** Friends, family, people who are gamers but not on the team
- **When:** You have a stable vertical slice or demo build
- **Goal:** "Does this make sense to someone who didn't build it?" -- finding confusion points, UX problems, difficulty spikes
- **Format:** Give them the build, hand them a feedback form, watch without helping

### 3. Blind Playtest (Target Audience)
- **Who:** People in your target audience who know nothing about the game
- **When:** You have a polished slice or near-complete build
- **Goal:** "Is this fun for the player it's designed for?" -- the real test of your design choices
- **Format:** Minimal instructions, no help, structured feedback collection

---

## Playtest Sessions

### Before the Session

1. **Define what you're testing.** Be specific. "Is the combat fun?" is too vague. Better: "Do players understand how to dodge? Is the timing window fair? Does combat feel impactful?"
2. **Prepare a build** that isolates what you're testing. Don't make them sit through a 10-minute tutorial to reach the thing you want tested.
3. **Write a feedback form** (see below)
4. **Set up recording** if possible -- screen capture or webcam. You'll catch things in video that you miss during the session.

### During the Session

1. **Give minimal instructions.** Say only what a player would know when they download the game from a store. If you have to explain how to play, your tutorial is broken.
2. **Do not help.** This is the hardest rule and the most important. When the player gets stuck, wait. Note how long it takes them to figure it out (or give up).
3. **Think aloud protocol.** Ask the player to narrate their thinking as they play. "I'm looking for an inventory... I see this button, I think it opens a map..."
4. **Watch their face and hands.** Frustration, confusion, boredom -- these are data points that words can't capture.
5. **Take notes, don't argue.** Every "but that's how it's supposed to work" is a wasted moment. Write it down. Fix it later.

### After the Session

1. **Debrief immediately.** While the session is fresh, write down:
   - What confused the player
   - Where they got stuck
   - What they enjoyed (and what they didn't)
   - Any bugs or crashes
2. **Prioritize issues.** Not all feedback requires action. Use this filter:
   - If one player reports something: note it
   - If two players report the same thing: investigate it
   - If three or more report the same thing: fix it
3. **Update your task tracker** with concrete action items

---

## Feedback Form Template

Use this for closed and blind playtests. Keep it short (5 questions max) so people actually fill it out.

```
FEEDBACK FORM - [Game Name] - [Date] - [Build Version]

Player Info (Optional):
- Age range:
- Games they usually play:
- How often they game:

1. What were you trying to do in the game? (What was your goal?)
   _______________________________________________

2. What was the most confusing part?
   _______________________________________________

3. What was the most fun part?
   _______________________________________________

4. On a scale of 1-10, how satisfying was [specific mechanic you're testing]?
   Score: ___  Why: _______________________________

5. If you could change one thing about the game, what would it be?
   _______________________________________________

Notes from observer (filled by the person running the session):
- Where the player got stuck and for how long:
- Moments of frustration (note timestamps if recording):
- Moments of engagement/excitement:
- Bugs or technical issues:
```

---

## Metrics to Track

Quantitative data complements qualitative feedback. Track these per build:

| Metric | How to Measure | What It Tells You |
|--------|---------------|-------------------|
| Time to first action | Start of play to first meaningful input | Tutorial clarity |
| Death/restart frequency | Count per session or per minute | Difficulty balance |
| Session length | Time from start to quit | Engagement/retention |
| Completion rate | % who finish the tested section | Pacing and motivation |
| Feature usage | Which mechanics get used vs. ignored | Design alignment with player behavior |

---

## Common Playtest Mistakes

| Mistake | Why It's Bad | Fix |
|---------|-------------|-----|
| Helping the player | Masks design problems you won't know about until release | Shut up and let them struggle |
| Testing your own work immediately after building it | You know exactly what to do, you're not the target audience | Have someone else test, or wait at least a day |
| Asking leading questions ("Did you like the combat?") | Gets polite yes/no instead of honest feedback | Ask open questions ("Tell me about your experience with...") |
| Collecting too much feedback from one person | One opinion isn't data | Get at least 3 players before making design changes based on feedback |
| Defending your design during the session | Player won't give honest feedback if they feel they're wrong | Thank them, note it, don't explain |
| Ignoring positive feedback | You need to know what WORKS as much as what doesn't | Note what players love and double down on it |
| Treating all feedback as gospel | Players are good at identifying problems, bad at suggesting solutions | Listen to the problem they describe. Their solution might be wrong -- the problem is real. |

---

## Playtest Cadence

| Project Phase | Playtest Frequency | Focus |
|--------------|-------------------|-------|
| Greybox / Prototype | Weekly (gut check) | Core mechanics, does the loop work |
| Vertical slice | Bi-weekly (closed) | Full experience, UX, difficulty |
| Production (feature-complete) | Monthly (blind) | Overall fun, pacing, polish gaps |
| Pre-release | As needed (blind) | Bugs, onboarding, first impressions |

---

## Version Tracking for Builds

Every playtest build should be versioned and documented:

```
Build: 0.1 - Combat Prototype
Date: YYYY-MM-DD
What's included: Player movement, basic attack, one enemy type
Known issues: No hit feedback, enemy AI is basic, no death state
What to test: Does combat feel good? Is movement responsive?
Where to get it: [path, drive link, etc.]
```
