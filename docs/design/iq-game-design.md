# Interview Questionnaire: Game Design

> **Purpose:** Define core mechanics, gameplay loops, progression systems, and player experience using proven game design frameworks.
> **Format:** Open discussion — record answers in this document or as follow-up notes.
> **Duration:** ~90-120 minutes
> **Recommended:** Play or briefly discuss 2-3 reference games before this session to warm up design thinking.

---

## Section 1: Game Identity & Audience

*Goal: Establish what the game is, who it's for, and what makes it distinct.*

1. **Describe the game in one sentence (high concept).**
   - Example format: "It's [Game A] meets [Game B] but with [Your Twist]."

2. **What are the 3 core pillars of this game?**
   - Pillars are non-negotiable design truths. Every feature must serve at least one.
   - Example: *Brutal combat, meaningful choices, emergent storytelling.*

3. **Who is the target player?**
   - Casual, mid-core, or hardcore?
   - Solo experience, co-op, or multiplayer?
   - What other games do they play?

4. **What is the fantasy the player is buying into?**
   - Not literal gameplay — the emotional fantasy. "I am a lord shaping the fate of a kingdom" vs. "I manage resource grids."

5. **What is the unique selling point (USP)?**
   - What can the player do in this game that they can't do anywhere else?

---

## Section 2: Core Gameplay Loop

*Goal: Define the moment-to-moment and session-to-session loops.*

6. **Describe what the player does in the first 60 seconds.**
   - This is your first impression. Walk through the exact sequence of actions.

7. **Describe what the player does in a typical 10-minute session.**
   - Identify the core loop: Action → Result → Feedback → Next Decision → Repeat.

8. **Describe what the player does over a 2-hour session.**
   - How does short-term play compound into medium-term goals?

9. **What is the session-to-session (meta) loop?**
   - What persists between play sessions? What pulls the player back?
   - Examples: territory expansion, story progression, character advancement, faction standings.

10. **Where does the game have downtime vs. high intensity?**
    - Map out a rhythm graph: rest/exploration → build-up → conflict → reward → rest.

---

## Section 3: Core Mechanics

*Goal: Define the actual systems the player interacts with.*

11. **What are the primary actions the player can take?**
    - Limit to 5-7. Examples: move, attack, negotiate, build, trade, recruit.
    - Which is used most? Which is the signature mechanic?

12. **How does movement and navigation work?**
    - Free roam, grid-based, node-based map, point-and-click?
    - How does the player traverse the world at ground level and at the strategic level?

13. **How does combat work (if applicable)?**
    - Real-time action, turn-based, tactical grid, RTS army command, or a hybrid?
    - What is the player's role: direct combatant, commander, or both?
    - What is the difficulty philosophy: punishing, forgiving, adjustable?

14. **What systems does the player manage?**
    - Resources (what kinds, how many)?
    - NPCs / retinue / vassals?
    - Territory / buildings / economy?
    - How complex should management be? Spreadsheet or lightweight?

15. **How do decisions and consequences work?**
    - Branching dialogue with plot impact, systemic world changes, or both?
    - How irreversible are player choices?

---

## Section 4: Progression & Motivation

*Goal: Define what drives the player forward and how they measure growth.*

16. **What does "progress" look like for the player?**
    - Character stats, territory size, story advancement, reputation, wealth?
    - Is progression vertical (bigger numbers) or horizontal (more options/tools)?

17. **What is the reward structure?**
    - Immediate (loot, XP), short-term (quest completion, leveling), long-term (story climax, endgame)?
    - How do rewards feel — numerical, narrative, mechanical, visual?

18. **How is difficulty and challenge handled?**
    - Curve: gentle ramp, spike-and-settle, dynamic, or flat?
    - How does the player learn mechanics? Tutorial, environmental affordance, failure as teaching?

19. **What are the mid-game and late-game scenarios?**
    - Mid-game: What keeps the player engaged after novelty wears off?
    - Late-game: What is the end goal, and does the game support post-endgame play?

---

## Section 5: Design References & Deconstruction

*Goal: Learn from existing games and define what to emulate or avoid.*

20. **Name 3 games you want this to feel like.**
    - For each: what specifically works in that game?
    - What would you do differently?

21. **Name 1-2 games that you want to AVOID feeling like.**
    - What didn't work in those games that we should learn from?

22. **Is there a non-game media reference (book, film, tabletop game) that defines the feel?**
    - Games as inspiration: *Mount & Blade, Crusader Kings, Bannerlord, Kingdom Come: Deliverance, RimWorld, Dwarf Fortress.*

---

## Section 6: Scope & Constraints

*Goal: Ground ambition in reality and prevent over-engineering.*

23. **What is the minimum viable version of the core loop?**
    - Strip everything away. What are the absolute minimum pieces needed for a 5-minute playable experience?

24. **What is the single biggest technical or design risk?**
    - What is hardest to build? Most likely to go over scope?
    - What's the mitigation plan?

25. **What features are "nice to have" vs. "must have" for launch?**
    - Be ruthless. Mark each idea as P0 (must), P1 (should), P2 (could), P3 (won't).

26. **What is an acceptable vertical slice?**
    - Describe a minimal-but-complete slice: one area, one enemy type, one quest, one mechanic fully polished.
    - How small can this be while still proving the core concept?

---

## Section 7: Decision & Action Items

*Capture concrete decisions, assigned tasks, and follow-up actions.*

### Decisions Made
-

### Open Questions (Research or Prototyping Needed)
| Question | How to Resolve | Assigned To |
|----------|---------------|-------------|
| | Prototype / Research / Decision | |

### Follow-Up Tasks
| Task | Assigned To | Deadline |
|------|-------------|----------|
| | | |

---

## Facilitator Notes

### Best Practices for This Session
- **Start broad, narrow later.** Don't debate edge cases until the core loop is clear.
- **Use "Yes, and..." not "No, but..." in brainstorm mode.** Save critique for the evaluation pass at the end.
- **Every mechanic must answer three questions:**
  1. What does the player DO?
  2. What does the player LEARN from doing it?
  3. Why does the player WANT to keep doing it?
- **Prototype early.** A paper prototype or digital greybox proves more than an hour of debate.
- **Beware feature creep.** If a mechanic doesn't serve a pillar, it's a candidate for cutting.
- **Use the "pillars test" for every idea:** Does it support pillar 1, 2, or 3? If none, cut it.
- **Document assumptions.** Many design disagreements come from unstated assumptions being different between team members.

### Recommended Frameworks to Keep in Mind
- **MDA Framework:** Mechanics → Dynamics → Aesthetics (what code creates → what emerges → what the player feels)
- **Core Loop Diagram:** Always draw it. One circle for moment-to-moment, one for meta.
- **Player Types (Bartle):** Achiever, Explorer, Socializer, Killer — who is our primary type?
- **Flow Theory:** Match challenge to skill. Map out where boredom and anxiety will occur.
