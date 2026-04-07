---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/project/indie-game-dev-guide.md
tags:
  - indie-dev
  - game-development
  - process
---

# Indie Game Development Process

A comprehensive guide for developers transitioning from software engineering to indie game development, covering the full lifecycle from concept to launch.

## Mindset Shift: Software Engineers to Game Developers

### The Engine Trap
Experienced developers often write custom engines. **Do not do this.** Building your own engine adds 1-2 years of invisible overhead. Use [[Technical Choices|Godot]] for everything you need.

### Over-Engineering Architecture
Game mechanics change constantly during iteration. Replace "bug-free and extensible" with "playable, clear, and shippable." Godot's node system and signals are sufficient for 95% of projects.

### The 70% You Are Not Expecting

| Activity | Percentage |
|---|---|
| Game logic / systems code | ~30% |
| Content, level design, art | ~30% |
| Polish, audio, animation, game feel | ~40% |

"Juice" -- hit pause, screen shake, tweening, sound feedback -- distinguishes a hobby project from a Steam release.

## Core Development Cycle

### 1. The Two Weeks Rule
Your **first complete game should take 2-4 weeks**. Start with a single-mechanic game, finish it, then scale up.

### 2. Core Loop Design
Every game has a core loop: **Input -> Action -> Feedback -> Reward**. Build this with grey boxes first. **If it is not fun with squares, no optimization will make it fun.**

### 3. MVP = Core Loop Prototype
Spend 2 days hacking together a mechanic with placeholder everything. If it fails, delete it. Senior developers struggle here because they try to make prototypes "correct" instead of "informative."

### 4. Vertical Slice
A **60-90 seconds of fully polished gameplay** that proves art style, performance, UI flow, and core fun. Build this AFTER the MVP is fun.

## Game Design: Casual, Educational, Medieval

### Casual Game Principles
- Short, self-contained core loops (5-10 minutes per cycle)
- Clear cause-and-effect
- Pause-and-plan pacing
- Remove artificial friction (fast undo/retry, auto-save)

### Medieval Design Lessons
- Ground mechanics in historical reality but streamline complexity
- Spatial planning and resource chains drive engagement
- Visual growth is highly rewarding
- Abstract historical complexity into readable mechanics

### Educational Games on Steam
- Entertainment must lead -- education emerges from mechanics
- Successful tags: `Educational`, `Historical`, `Strategy`, `Simulation`, `Relaxing`, `Singleplayer`
- Show core loop in first 30 seconds of trailer

## Realistic Timeline (Part-Time)

| Phase | Duration | Deliverable |
|---|---|---|
| Core Loop Prototype | Weeks 1-4 | Greybox with basic UI |
| Vertical Slice | Months 2-3 | One level with final art style |
| Content Expansion | Months 4-8 | Multiple levels, playtest iteration |
| Polish & Prep | Months 9-12 | Bugfixes, store assets |
| Marketing Push | Months 10-14 | Next Fest, wishlists |
| Launch | Month 14+ | Steam release |

**Multiply your gut estimate by 3x** for part-time reality.

## See Also

- [[Development Milestones]]
- [[Ethical Design]]
- [[Community Building]]
- [[Steam Publishing]]
- [[Player Psychology]]
- [[Part-Time Development]]
