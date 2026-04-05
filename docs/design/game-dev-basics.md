# Game Development Basics

> **Purpose:** Plain-language introduction to core game development concepts for first-time developers.
> **Audience:** Anyone on the team who hasn't shipped a game before.
> **Read this first** before diving into design docs or code.

---

## What Is a Game?

At its simplest: **a game is a system of rules that a player interacts with to create an experience.**

Everything else -- story, art, music, menus -- is decoration on top of that system. The system must work first. A beautiful game with broken rules is frustrating. An ugly game with solid rules can still be fun.

---

## The Game Development Pipeline

Making a game happens in stages. Each stage answers different questions. Do them in order. Skipping stages is the #1 reason first-time projects fail.

### 1. Concept (Answer: "What are we making?")
- Core idea, target audience, similar games
- Keep it to one page. If you can't explain the game in one page, it's too complex.

### 2. Pre-Production (Answer: "How will it work?")
- Design documents, prototypes, art style tests, tech research
- Nothing is final yet -- everything is a hypothesis to test
- **This is where you figure out what not to make** (just as important as what to make)

### 3. Production (Answer: "Let's build it.")
- Create all the content: levels, art, code, audio, writing
- The longest phase. This is where scope creep will try to kill your project.
- Work in iterations: build the smallest version first, then add to it.

### 4. Polish (Answer: "Does it feel good?")
- Fix bugs, improve timing, add juice (screen shake, particles, sound effects)
- Polish is not optional. Rough polish is the difference between a playable game and a fun game.

### 5. Release (Answer: "It's in the wild.")
- Final testing, optimization, publishing, and marketing

---

## Core Concepts You Need to Know

### The Game Loop

The game loop is the heartbeat of every game. It runs continuously while the game is active:

```
1. Read player input (keyboard, mouse, controller)
2. Update the game state (move characters, check collisions, run AI)
3. Render everything to the screen
4. Repeat -- typically 60 times per second
```

Everything in your game happens inside this loop. When something doesn't work, the bug is always in step 1 (input), step 2 (logic), or step 3 (output).

### Mechanics, Dynamics, Aesthetics (MDA)

This is the most widely used framework for thinking about game design. Three layers:

- **Mechanics** -- The rules and code. "Pressing E picks up an item." "Swords deal 10 damage." Mechanics are what the developer builds.
- **Dynamics** -- What happens when mechanics run during play. "The player picks up a health potion right before a sword hit, then charges into the next fight." Dynamics emerge from mechanics interacting with player choices.
- **Aesthetics** -- What the player feels. "That was intense and rewarding." Aesthetics are the emotional experience.

**Key insight:** You build mechanics, but the player experiences aesthetics. You can't code "fun" -- you code systems that produce fun as a side effect.

**Example in our game:**
- Mechanic: A lord sets a tax rate on their territory.
- Dynamic: High tax causes peasants to rebel; low tax pleases them but drains the treasury.
- Aesthetic: The player feels the tension of ruling -- the weight of hard choices.

### The Core Loop

Every game has a core loop -- the 30-second to 2-minute cycle of actions the player repeats over and over.

**Example from a generic game:**
Fight enemies → Collect loot → Upgrade gear → Fight stronger enemies

**Your job as a designer is to make this loop satisfying.** If the core loop isn't fun in a bare-bones greybox prototype, no amount of art or story will fix it.

### Scope

Scope is the total amount of content and features in your game. **First-time developers almost always overestimate what they can build.**

Rules of thumb:
- Your first game should take half the time you think it will
- Cut 50% of your planned features before you start
- If you still can't finish, cut 50% again
- A tiny, polished game is better than a huge, broken one

### The Vertical Slice

A vertical slice is a **tiny but fully playable and polished** portion of the game. It proves the concept works before you build the whole thing.

Think of it like a restaurant tasting -- one complete dish, not a list of ingredients.

**For our feudal game**, a vertical slice might be:
- One small territory
- One NPC interaction
- One combat encounter or decision
- One piece of progression (earn money, pay a tax, see the result)

All fully working, tested, and polished. If this isn't fun, the full game won't be either.

---

## Common Terms You'll Hear

### Code / Programming
- **Script** -- A chunk of code that controls one thing (a door, an enemy, a UI element).
- **Variable** -- A named container for data. `health = 100`. `gold = 50`. The game reads and changes these to track state.
- **Function / Method** -- A reusable block of code that does one thing. `FireArrow()`, `OpenDoor()`, `CalculateTax()`.
- **Bug** -- Something that breaks. It could crash the game or just behave weirdly. All games have bugs. The question is how many.
- **Engine** -- The software framework that makes the game run (Unity, Unreal, Godot). It handles rendering, physics, input, audio, and more so you don't have to build those from scratch.

### Art / Visuals
- **Sprite** -- A 2D image used in a game (characters, items, UI icons).
- **Mesh / Model** -- A 3D shape made of polygons. Everything 3D in a game is a mesh -- characters, trees, buildings.
- **Texture** -- An image wrapped around a 3D model to give it color and detail.
- **Animation** -- A sequence of frames that make something appear to move.
- **Collider** -- An invisible shape around an object that determines what the player can bump into or pass through. Colliders are why your character doesn't fall through the floor.
- **UI (User Interface)** -- Everything on screen that isn't the game world: health bars, menus, buttons, inventory screens.

### Audio
- **SFX (Sound Effects)** -- Short sounds tied to specific actions (sword swing, door open, coin collect).
- **BGM / Music** -- Longer soundtrack that plays during gameplay.
- **Ambient** -- Continuous background sounds (wind, birds, crowd noise). These make the world feel alive.
- **Mix** -- Balancing all audio volumes so nothing overpowers anything else.

### Project / Process
- **Prototype** -- A rough, unfinished version built to test one specific idea. It's okay if it's ugly. It's supposed to be.
- **Placeholder / Greybox** -- Temporary art (grey cubes, basic shapes) used while building mechanics so you don't wait on art to test gameplay.
- **Iteration** -- The process of building, testing, improving, and repeating. Game dev is not "build it once, it's done." It's "build a version, test it, find what's wrong, build a better version." Repeat until it's good.
- **Gold Master** -- The final build submitted for release. No more changes after this point.

---

## The Golden Rules for First-Time Developers

### 1. Start stupid small
Your first project should be so simple it seems almost embarrassing. A single room. Two mechanics. One goal. Prove you can finish something before attempting something big.

### 2. Prototype before committing
Never commit to a mechanic you haven't played. If you can't make a paper prototype or a 30-minute digital greybox, the idea is too complex to start with.

### 3. Ship is a feature
An unfinished game teaches you almost nothing. A finished game -- even a bad one -- teaches you the entire pipeline. Aim to finish.

### 4. Polish is not optional
The difference between an amateur project and a professional one is rarely the underlying technology. It's juice: screen shake, hit sounds, smooth animations, responsive controls, satisfying feedback. Polish makes simple mechanics feel great.

### 5. Playtest early and often
You are not the player. After building something three times, you know exactly what to do and what to expect. A fresh player will be confused, break things, and find bugs you can't imagine. Watch someone play without helping them. Take notes. Fix what frustrates them.

### 6. Cut without mercy
If a feature isn't core to the pillars and it's causing problems, cut it. A game with 3 excellent mechanics is better than one with 10 mediocre ones. Everyone who's shipped a game has a graveyard of features they were attached to but removed.

---

## Recommended Reading & Resources

- **"The Art of Game Design" by Jesse Schell** -- The best single introduction to game design thinking.
- **"Game Feel" by Steve Swink** -- Deep dive into why some games feel good to control and others don't.
- **GDC YouTube channel** (youtube.com/gdconf) -- Free talks from professional developers on every topic imaginable.
- **Game Maker's Toolkit** (youtube.com/@GMTK) -- Excellent video essays on game design concepts.

---

## Questions?

If something in this document (or any other doc) doesn't make sense, ask. There are no dumb questions in pre-production -- only unasked ones that become expensive problems later.
