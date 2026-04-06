# Indie Game Development: From Scratch to Steam

> A comprehensive research report for experienced software developers starting their first game project.

**Date:** April 2026  
**Sources:** Reddit (r/gamedev, r/godot, r/gamedesign, r/Steam, r/indiegaming), GDC/GamaSutra postmortems, TIGSource, GameDev.net, Godot documentation, indie dev blogs  
**Scope:** Hobby-level PC game (Windows/Linux), Godot engine, medieval educational theme, casual-friendly, no dark patterns

---

## Table of Contents

1. [Mindset Shift: Software Engineers to Game Developers](#1-mindset-shift-software-engineers-to-game-developers)
2. [Scope & Planning: Your First Game](#2-scope--planning-your-first-game)
3. [The Core Loop, MVP, and Vertical Slice](#3-the-core-loop-mvp-and-vertical-slice)
4. [Godot Engine Guide](#4-godot-engine-guide)
5. [Project Structure & Git Workflow](#5-project-structure--git-workflow)
6. [Game Design: Casual, Educational, Medieval](#6-game-design-casual-educational-medieval)
7. [Ethical Design: Avoiding Dark Patterns](#7-ethical-design-avoiding-dark-patterns)
8. [Art & Audio Pipeline](#8-art--audio-pipeline)
9. [Player Psychology & Reward Systems](#9-player-psychology--reward-systems)
10. [Accessibility](#10-accessibility)
11. [Playtesting](#11-playtesting)
12. [Part-Time Development & Team Workflow](#12-part-time-development--team-workflow)
13. [Community Building & Devlogs](#13-community-building--devlogs)
14. [Steam Publishing & Marketing](#14-steam-publishing--marketing)
15. [Alternative Platforms](#15-alternative-platforms)
16. [Legal, Taxes & Business](#16-legal-taxes--business)
17. [Realistic Timeline](#17-realistic-timeline)
18. [Common Mistakes Checklist](#18-common-mistakes-checklist)
19. [Recommended Resources](#19-recommended-resources)

---

## 1. Mindset Shift: Software Engineers to Game Developers

You have 10-15 years of professional experience. This is both your greatest asset and your biggest trap. Here is what you need to know about the difference between software development and game development.

### The Engine Trap

Experienced developers often write custom engines or build massive frameworks to solve problems they have not encountered yet. **Do not do this.** Game engines (Godot, Unity, Unreal) exist to solve rendering, physics, and input pipelines so you can focus on gameplay. Building your own engine adds 1-2 years of invisible overhead. Godot is a solid, free, open-source choice that handles everything you will need.

### Over-Engineering Architecture

Software engineering emphasizes maintainability, scalability, and clean interfaces. Game mechanics change constantly as you tweak what is fun. Highly rigid architectures resist iteration.

> **"Your codebase will be messy, and that is okay. If the mechanics change, throw the code away."** -- TIGSource veteran

Replace "bug-free and extensible" with "playable, clear, and shippable." Optimize for player comprehension and finish rate, not architectural elegance. Godot's node system and signals are enough for 95% of projects. Avoid custom ECS, excessive abstraction layers, or premature optimization.

### The 70% You Are Not Expecting

Software devs assume game dev is 90% logic and 10% assets. In reality:

| Activity | Percentage |
|---|---|
| Game logic / systems code | ~30% |
| Content, level design, art | ~30% |
| Polish, audio, animation, game feel | ~40% |

"Juice" -- hit pause, screen shake, tweening, sound feedback -- is what distinguishes a hobby project from a Steam release. Never cut the polish phase.

### Agile Does Not Work Exactly the Same

You cannot write a perfect Sprint backlog for gameplay before you know if it is fun. **Requirements emerge from playtests.**

**Recommended hybrid approach:**
- Use Agile/kanban for asset pipeline, bug tracking, and audio integration (your strength)
- Use iterative, time-boxed prototyping sprints for game design
- Write a dynamic 1-page Game Design Document (GDD)
- Do not write a 50-page spec; update the GDD only after code proves a mechanic

---

## 2. Scope & Planning: Your First Game

### The "Two Weeks" Rule

The community consensus on r/gamedev is that your **first complete game should take 2-4 weeks**. If it takes longer, you are over-scoping. This does not mean your Steam game -- it means your learning project.

> **"Pong but slightly different."** Do not start with an RPG, a platformer, or anything with multiplayer. Start with a single-mechanic game, finish it, then scale up.

### Scope Is Technical Debt for Fun

Treat scope like technical debt. Cut features ruthlessly. If a mechanic does not directly feed the core loop, delete it or table it for a sequel.

> **"You do not finish games by adding time, you finish games by cutting content."**

### Scoping for Hobby Timelines

For a hobby project with evenings and weekends:
- Multiply your initial estimate by **3x to 4x** for part-time reality
- A "3-month game" is typically 9-12 months
- First commercial-quality release: **12-18 months** part-time for a 2-3 person team aiming for 2-3 hours of polished gameplay

---

## 3. The Core Loop, MVP, and Vertical Slice

### Core Loop

Every game has a core loop: **Input -> Action -> Feedback -> Reward**. You must be able to simulate this with grey boxes and dummy sprites. **If it is not fun with squares, no amount of optimization will make it fun.**

For a medieval educational game, a core loop might look like:
> Observe the situation -> Plan your approach -> Execute -> See the result -> Learn something -> Adjust strategy

Keep sessions to 15-30 minutes with natural save/exit points.

### MVP = Core Loop Prototype

The MVP in game dev is not a playable game -- it is a working core loop with placeholder everything. Spend 2 days hacking together a mechanic. If it fails, delete it. Senior devs struggle here because they try to make the prototype "correct" instead of "informative."

### Vertical Slice

A vertical slice is **60-90 seconds of fully polished gameplay**. It proves the art style, performance, UI flow, and core fun. Build this AFTER the MVP is fun. Use it to align your team on what "Done" actually looks like.

**Build your vertical slice to cover:**
- One complete interaction or level
- Final-quality art style (or close to it)
- UI mocked up and functional
- Basic audio in place
- The full core loop from start to resolution

---

## 4. Godot Engine Guide

### Godot 3 vs Godot 4

**Use Godot 4.** It has better performance, a redesigned renderer, improved 2D and 3D pipelines, and active development. Godot 3 is effectively in maintenance mode for new projects. The main reasons people stayed on 3 were addon compatibility, and most popular addons have been ported by now.

### GDScript vs C# for Your Team

Given your C/C++/systems development background, you might be tempted to go straight to C#. Consider this:

| Aspect | GDScript | C# |
|---|---|---|
| Learning curve | Minutes for any programmer | Minimal, but Godot-specific bindings to learn |
| Hot-reload | Excellent (instant) | Good (but slower) |
| Performance | Adequate for 2D casual games | Better for heavy computation |
| Community tutorials | Majority are GDScript | Growing but smaller |
| Integration | Native, first-class | Requires .NET SDK setup |

**Recommendation:** Start with GDScript for the prototype and vertical slice. It will let you iterate fastest. If you hit genuine performance limits (unlikely for a casual 2D game), migrate performance-critical systems to C# or GDExtension (C++).

### Godot Strengths for Your Project

- **Lightweight:** Editor opens in seconds, project size stays small
- **Node-tree architecture:** Intuitive for programmers who understand composition
- **Built-in 2D pixel-perfect rendering:** Excellent for casual games
- **No licensing drama:** MIT license, truly free, no revenue share
- **Single-click export:** Windows and Linux export are straightforward
- **Strong 2D support:** TileMaps, SpriteFrames, AnimationPlayer are production-ready

### Godot Weaknesses to Know About

- **Smaller ecosystem** than Unity/Unreal -- fewer ready-made plugins
- **Asset store is less mature** -- you will build more from scratch
- **3D is capable but not its strength** -- irrelevant if you are doing 2D
- **Debugging tools are basic** compared to Unity's profiler
- **Documentation has gaps** -- community forums and YouTube fill the gaps

---

## 5. Project Structure & Git Workflow

### Recommended Folder Structure

```
project/
  assets/              # All imported art and audio
    art/
      characters/
      environments/
      ui/
      vfx/
    audio/
      music/
      sfx/
      ambient/
  docs/                # Your existing markdown documentation
    design/
    tech/
    project/
  scenes/              # .tscn files
  scripts/             # .gd or .cs files
  resources/           # .tres data files (items, stats, configs)
  shaders/             # Shader files
  fonts/
  builds/              # (gitignored) Exported builds
  .gitignore
  project.godot
```

### Git Configuration

```gitignore
# Godot
.godot/import/
.godot/uid*
*.uid
.import/

# IDEs
.vscode/
.idea/
*.swp
*.swo

# Builds
builds/
exports/

# OS
.DS_Store
Thumbs.db
```

### Git Best Practices

- Use **Git LFS** for all audio, textures, models, and binaries over 50MB
- **Trunk-based development** or short-lived feature branches (1-3 days max)
- Small, atomic commits. Separate scene changes from script changes when possible
- Use **pull requests with code review** even for 2-3 people -- catches bad merges before they block playtests
- **Never manually edit .tscn/.tres** files unless you understand the resource syntax

### Merge Conflict Prevention in Godot

- Split monolithic scenes into sub-scenes (UI panels, logic controllers, props, audio)
- Use signals and events instead of hard node references
- Prefer **resource-driven data** (.tres files) over hardcoded values
- Externalize content (quests, facts, stats) to JSON/CSV and import via scripts -- keeps data out of Git conflicts

---

## 6. Game Design: Casual, Educational, Medieval

### What Makes Casual Games Work

- **Short, self-contained core loops** (5-10 minutes per meaningful cycle)
- **Clear cause-and-effect:** player action -> immediate feedback -> visible result
- **Pause-and-plan pacing** -- respect that casual players may not have hours to burn
- **Remove artificial friction:** fast undo/retry, auto-save, skip/replay options for tutorials
- Gate progression through **player understanding and mastery**, not repetitive tasks or time-walls

### Educational Games on Steam

**Entertainment must lead. Education should emerge from mechanics, not replace them.**

Successful Steam tags for educational games: `Educational`, `Historical`, `Strategy`, `Simulation`, `Relaxing`, `Singleplayer`

**Teach through systems:** let players experiment, fail safely, and discover historical/logical rules organically. Never lecture.

**Store page advice:** Show the core loop in the first 30 seconds of your trailer. Explicitly state learning outcomes without sounding academic.

### Medieval Game Design Lessons

From successful titles (Kingdom Come Deliverance, Banished, Manor Lords, Anno, Stronghold):

- **Kingdom Come Deliverance:** Ground mechanics in historical reality, but streamline complexity. Use contextual storytelling.
- **Banished / Manor Lords:** Spatial planning and resource chains drive engagement. Visual growth is highly rewarding. Clear UI/UX is critical.
- **Anno / Stronghold:** Interconnected production systems work best when UI is clean, tooltips are available, and automation unlocks naturally.

**Core takeaway:** Abstract historical complexity into readable mechanics. Use an in-game codex, environmental cues, and contextual footnotes.

### Medieval Visual Identity

- Limit to **16-32 colors** total -- medieval themes benefit from muted earth tones, iron grays, cool shadow hues
- Pick **one light direction** and paint shadows uniformly
- Either use clean line art OR go fully pixel/cel-shaded -- never mix styles
- Apply a single color correction pass to force all assets into the same tonal range

---

## 7. Ethical Design: Avoiding Dark Patterns

Your game explicitly avoids dark patterns. Here is a framework for what to remove and what to use instead.

### Remove These

- FOMO timers and countdowns
- Daily login gates or streak trackers
- Energy systems that prevent play
- Loot boxes or RNG-based paid rewards
- Pay-to-progress mechanics
- Manipulative push notifications
- Artificial scarcity

### Replace With

- Player-controlled pacing
- Transparent progression systems
- Permanent saves and easy re-entry
- Optional side objectives
- Clear exit/save states
- Honest difficulty curves

### If Monetizing

- Premium one-time purchase only
- Post-launch cosmetic or content DLC
- **Never** tie core progression to money or artificial scarcity

### Ethical Benchmark

> **"The player should feel respected, not optimized for retention metrics. Design for session completion, not session extension."**

---

## 8. Art & Audio Pipeline

### Recommended Art Styles for Small Teams

| Style | Pros | Cons | Verdict |
|---|---|---|---|
| **Pixel Art** | High control, natural for casual, massive tool support | Frame-by-frame animation is slow | **Best choice** for 2D medieval |
| **Low-Poly 3D** | Skeletal animation replaces frame work, lighting does the heavy lifting | Requires Blender skills | Good if team wants 3D |
| **Vector Art** | Resolution-independent | Tends to look corporate/mobile-gamey | Not ideal for medieval |
| **2D Hand-Drawn** | Visually stunning | Extremely labor-intensive | Avoid unless outsourced |

### Art Tools

- **Aseprite** ($20) -- industry standard for pixel art. Tileset editing, Godot SpriteFrames export
- **Piskel** -- free browser alternative. Good for quick loops
- **Krita / GIMP** -- free digital painting for placeholders and UI
- **Godot AnimationPlayer** -- handles timelines, tweens, state transitions. Sufficient for most needs

### Audio Tools

- **Bfxr / Sfxr** -- quick SFX generation (impacts, magic, UI sounds)
- **Audacity** -- free audio editing, normalization, EQ
- **Freesound.org** -- metal, wood, stone field recordings (check licenses)
- **Sonniss GDC Bundles** -- annual free archive of production-quality SFX
- **BeepBox.co** -- browser-based looping composition
- **Bosca Ceoil** -- offline, simple music creation
- **LMMS** -- free DAW with VST support
- **Spitfire LABS / Versilian Studios** -- free acoustic VSTs for medieval feel

### Audio Pipeline

- Export 16/24-bit WAV files
- Assign tracks to dedicated audio buses at import: Master, Music, SFX, UI, Ambient
- Use compression/reverb on **buses**, not per-file
- For medieval combat, layer 2-3 recordings (sword swing + leather rustle + impact) and pan in Godot
- Avoid OGG looping unless using seamless markers -- WAV prevents clicks

### Free Asset Resources

| Resource | License | Quality | Notes |
|---|---|---|---|
| **Kenney.nl** | CC0 (public domain) | Excellent | Recognizeable -- recolor before shipping |
| **OpenGameArt.org** | Mixed (filter for CC0) | Variable | Good base medieval props |
| **Itch.io asset packs** | Mixed | Wide range | Largest marketplace, filter CC0 |
| **Sonniss GDC archives** | CC0 | Professional | Best free SFX source |
| **Freesound.org** | Mixed | Variable | Great for field recordings |

### Outsourcing vs In-House

**Hybrid approach:**
- Learn Aseprite/Krita for prototyping, UI tweaks, and placeholder generation
- Outsource final polish for key visuals: hero character, 3-5 key enemies, modular tileset masters
- Budget: $50-200 per sprite sheet, $100-500 per music track
- Platforms: Fiverr, Upwork, ArtStation, game dev Discord servers
- **Never mix unmodified asset styles** -- recolor, tile, or shader-process all imports to maintain cohesion

### Godot Import Settings (2D Pixel Art)

- Texture Filter: **Nearest** (not Linear)
- Disable Mipmaps for 2D pixel art
- Enable "Force Square Pixels" in project settings
- Set audio Bus, Loop mode, and Stream format at import

---

## 9. Player Psychology & Reward Systems

Align your reward design with **Self-Determination Theory**:

| Need | Implementation |
|---|---|
| **Autonomy** | Meaningful choices in strategy, base layout, route planning |
| **Competence** | Clear skill progression, readable systems, informative feedback |
| **Relatedness** | Shared lore, community features, legacy tracking |

### Healthy Rewards (Use These)

- Unlock new tools, options, or capabilities
- Narrative and contextual payoffs
- Player expression (customization, layout choices)
- Mastery milestones that prove growth

### Unhealthy Rewards (Avoid These)

- Leaderboards that punish casual players
- Arbitrary point systems disconnected from gameplay
- Streak trackers that create anxiety
- Random loot boxes that feel exploitative

### Flow Maintenance

- Match challenge to player skill
- Provide immediate, readable feedback
- Make setbacks informative rather than punitive
- Difficulty sliders are essential for casual/educational games

---

## 10. Accessibility

Your casual, educational game should be accessible to as wide an audience as possible.

### Visual Accessibility

- Colorblind-safe palettes (test with simulators)
- Scalable UI and fonts
- High-contrast modes
- Clear iconography, not text-only cues

### Cognitive Accessibility

- Consistent UI patterns throughout
- Pause-and-play mode
- In-game glossary/codex for medieval terms
- First-encounter tooltips for new mechanics
- Adjustable difficulty sliders
- Reduce UI clutter

### Motor & Audio Accessibility

- Fully remappable controls
- Toggle vs hold options (no rapid-key requirements)
- Full controller support
- Customizable subtitles
- Separate audio mixing sliders (music, SFX, ambient, UI)

### Godot Implementation

- Use **Control node themes** for consistent, scalable UI
- **InputRemapping** for control rebinding
- Canvas modulation for global contrast adjustments
- Signals for all UI interactions to keep logic clean

---

## 11. Playtesting

### When to Start

**Week 3-4 with a greybox of the core loop.** Do not wait for art or polish. You are testing whether the game is fun, not whether it looks good.

### Cadence

- Weekly internal playtests (your team)
- Bi-weekly external tests (friends, target audience, teachers/students for educational focus)

### Method

1. **Unmoderated first.** Watch silently. Record where players hesitate, click incorrectly, or drop off.
2. Ask specific questions: **"What was your goal here?"** NOT "Did you like it?"
3. Track time-to-fun, confusion points, and learning retention
4. For educational games: measure comprehension vs frustration

### Expect to Kill 30-50% of Early Features

This is normal and saves months of wasted work. Players will not interact with your game the way you designed. That is data, not failure.

### Tools

- Screen recording (OBS)
- Simple feedback forms
- Godot analytics plugin (add later)

---

## 12. Part-Time Development & Team Workflow

### Time Management

- **Cap weekday sessions at 1-2 hours**
- Use weekends for longer focus blocks (3-4 hours max)
- Track outcomes, not hours
- Ship one small playable piece per week
- Zero days are normal -- plan for 10-15 productive hours/week/team, not 20

### Burnout Prevention

- Treat dev time like a **protected hobby, not a second job**
- Decouple learning from production -- separate sessions for tutorials vs shipping
- Enforce hard boundaries: no crunch, no guilt for missed weeks
- Rotate roles weekly (code vs design vs pipeline) to avoid fatigue
- Take planned hiatuses (2-4 weeks) when motivation dips

### Burnout Signals

- Dreading sessions
- Refactoring instead of shipping
- Ignoring playtest feedback
- Working past planned cut-off time

### Maintaining Motivation

- Build a visible, playable milestone by **week 6**
- Break work into "fun-sized" deliverables
- Ship a mini-build every 2 weeks
- Accept scope as a feature, not a failure
- Tie development to your mission: "We are making history accessible and fun"

---

## 13. Community Building & Devlogs

### Platform Strategy

| Platform | Role | Time Investment |
|---|---|---|
| **Itch.io devlog** | Primary devlog hub | 30 min per post |
| **Discord server** | Community hub | 30 min/day |
| **Reddit** | Weekly threads, feedback | 1-2 hrs/week |
| **YouTube/TikTok** | Only if <2 hrs/week | Optional |

### Content Cadence

- Post every **2-4 weeks**
- Show process, failures, and small wins
- Reuse screenshots and clips from builds
- Avoid overproducing -- dev time > marketing time

### Educational Niche Advantage

Share how mechanics map to learning objectives. Tag teachers, historians, or homeschool communities. Offer early teacher preview builds for feedback and distribution.

### When to Go Public

Do not announce until you have a **10-15 minute polished vertical slice** with:
- Stable controls
- Basic UI
- A clear learning loop

### Soft Launch Path

1. Private alpha: friends, local schools, Discord testers
2. Public demo: Itch.io page + simple landing page + email capture
3. Wishlists/store prep: only when 70%+ content is finalized

**Avoid early Steam announcements** unless you have a dedicated marketing timeline. Steam favors sustained visibility.

---

## 14. Steam Publishing & Marketing

### Steam Direct

- One-time **$100 USD** submission fee per title
- Recoupable after $1,000 in gross revenue
- Requires identity verification, tax interview, and a playable build
- Store page approval: ~30 days
- Build review: ~5 business days

### The Wishlist Game

**Wishlists are the single strongest predictor of launch success.**

- Each wishlist converts to ~30-50% sales at launch
- Triggers algorithmic boosts on Steam
- Target: **7,000-10,000 wishlists minimum** for reliable visibility
- 20,000+ puts you in contention for "Popular Upcoming" and "New & Trending"

### Steam Page Timing

**Create your Steam page as early as possible** (ideally 6-12 months before launch). You need:
- Polished capsule art (non-negotiable)
- Short gameplay trailer (60 seconds)
- Clear feature list and screenshots
- Accurate genre tags

### Steam Next Fest

This is the most cost-effective visibility tool for indie devs. Held in February, June, and October.

- Participate with a polished, replayable vertical slice (15-30 minutes)
- Drives massive wishlist accumulation
- Free and open to all Steam partners

### Pricing

- Casual/educational sweet spot: **$9.99 - $14.99 USD**
- $19.99 possible if content depth is clear
- Enable Steam's regional pricing automatically
- Do not underprice -- it signals low effort and increases support load
- Price anchor against comparable titles using SteamDB

### Launch Strategy

```
Public Demo -> Steam Next Fest -> Wishlist Accumulation -> Launch
```

- Avoid launching during AAA-heavy windows or major sales
- Cross-promote via Discord, Reddit devlogs, YouTube dev diaries
- Consider a minor launch discount (10-20%) for algorithmic "sale" visibility

### What Makes or Breaks a Launch

**Makes:**
- Exceptional capsule art
- Clear genre tags
- Consistent marketing cadence
- Next Fest participation
- Transparent dev updates
- Quick post-launch patches
- Accurate store description

**Breaks:**
- Buggy launch build
- Vague or poor capsule art
- No external marketing
- Ignoring community feedback
- Overpromising features
- Misaligned pricing
- Launching without a wishlist baseline
- Radio silence post-launch

### Post-Launch

- First 7-14 days dictate algorithm trust -- aim for "Very Positive" (80%+)
- Refund policy: <2 hours or <14 days = automatic refund. Hook players within 30 minutes.
- **Patch fast.** Silent post-launch = death for indie momentum
- Engage with reviews politely. Steam tracks review sentiment for queue placement.

---

## 15. Alternative Platforms

### Itch.io

- **Pros:** Zero barrier to entry, dev-friendly, customizable storefront, pay-what-you-want, excellent for prototyping/educational distribution
- **Cons:** Minimal organic discoverability, smaller player base
- **Verdict:** Excellent companion store or early access testing ground. Do not expect Steam-level sales.

### GOG

- **Pros:** DRM-free, highly engaged PC audience, curated store, strong for strategy/classic feel
- **Cons:** Highly selective, manual curation, lower traffic for niche casual, often requires publisher intro
- **Verdict:** Good for a DRM-free bundle later. Do not rely on it for primary launch revenue.

### Epic Games Store

- **Pros:** 88/12 revenue split, strong PC user base
- **Cons:** Heavily curated/invite-only for indies, low organic discoverability
- **Verdict:** Submit through their developer portal, but treat as secondary to Steam.

---

## 16. Legal, Taxes & Business

### Business Entity

- Form an **LLC** (or local equivalent)
- Separates personal liability, simplifies taxes
- Required by most payment processors and publishers
- Open a dedicated business bank account

### Taxes

- Complete Steam's tax interview (W-9 for US, W-8BEN for non-US)
- Steam withholds 30% unless a tax treaty applies
- Track all dev expenses (assets, software, Steam fee, contractors) as deductions

### VAT & Sales Tax

**Steam acts as the Merchant of Record.** They automatically collect and remit EU VAT, UK VAT, US state sales taxes, and most territorial digital taxes. You receive net payments. Keep financial records for local corporate tax filing.

### IARC Rating

- Steam does not require official age ratings -- you self-declare
- **IARC** (International Age Rating Coalition) is free/low-cost and auto-generates PEGI, USK, ESRB ratings
- Strongly recommended for educational/casual titles to signal trust
- Use tags carefully: emphasize "Educational", "Casual", "Strategy" -- avoid "Gore" or "Violence" unless accurate

### Contracts

- If using freelancers or artists, use signed **Work-For-Hire agreements**
- Clarify IP ownership, revenue share, and credit
- Protect your original medieval/educational content early

---

## 17. Realistic Timeline

For a 2-3 person team working part-time on a hobby project aiming for a 2-3 hour polished game:

| Phase | Duration | Deliverable |
|---|---|---|
| Core Loop Prototype | Weeks 1-4 | Greybox working core loop, basic UI, fun test |
| Vertical Slice | Months 2-3 | One level/quest with final art style, audio, menus |
| Content Expansion | Months 4-8 | Multiple levels/tutorials, playtest iteration |
| Polish & Prep | Months 9-12 | Bugfixes, store assets, export testing |
| Marketing Push | Months 10-14 | Next Fest, wishlists, community building |
| Launch | Month 14+ | Steam release, Day 1 patch |

**Multiply your gut estimate by 3x.** This is the single most cited piece of advice across every source.

---

## 18. Common Mistakes Checklist

Before you start, review this. These are the most cited mistakes from experienced programmers entering game dev:

### Project Mistakes

- [ ] Writing a custom engine instead of using Godot
- [ ] Over-engineering the architecture before knowing what is fun
- [ ] Starting with too large a scope (RPG, multiplayer, open world)
- [ ] Not building a vertical slice before committing to full development
- [ ] Treating Agile sprints as if game features are independent tasks
- [ ] Ignoring the asset pipeline until late in development
- [ ] Believing "we will polish it later"

### Design Mistakes

- [ ] Assuming players will figure things out without tutorials
- [ ] Making education the primary mechanic instead of a byproduct
- [ ] Adding grind or artificial time gates
- [ ] No clear core loop or feedback on player actions
- [ ] UI that requires reading instead of understanding at a glance

### Process Mistakes

- [ ] Not playtesting until the game is mostly finished
- [ ] Building in isolation without community or feedback
- [ ] No time boundaries leading to burnout
- [ ] Perfectionism blocking shipping
- [ ] Not validating the export pipeline on target OS early

### Publication Mistakes

- [ ] Creating Steam page too late
- [ ] Launching without wishlist baseline
- [ ] Poor capsule art or unclear store page
- [ ] No post-launch patch plan
- [ ] Ignoring reviews and community feedback after launch

---

## 19. Recommended Resources

### Essential Reading

- **"Level Up! The Guide to Great Video Game Design"** by Scott Rogers
- **"The Art of Game Design: A Book of Lenses"** by Jesse Schell
- **r/gamedev Wiki:** https://www.reddit.com/gamedev/wiki/faq/
- **GamaSutra/GDC Postmortems:** https://www.gamedeveloper.com/
- **"The First Game You Make Should Be Bad"** -- widely shared community essay

### GDC Talks

- "100 Tips for a Better Game" -- design principles
- "Designing for Accessibility in Games" -- accessibility
- "How to Nail Your First Playtest" -- playtesting
- "The Indie Marketing Checklist" -- marketing on a budget

### Godot Resources

- **Official Documentation:** https://docs.godotengine.org/
- **GDQuest YouTube:** tutorials and best practices
- **HeartBeast YouTube:** 2D game tutorials
- **KidsCanCode YouTube:** beginner-friendly Godot tutorials
- **Godot Asset Library:** built into the editor

### Communities

- **r/gamedev** -- general game development
- **r/godot** -- Godot-specific help
- **r/gamedesign** -- design theory and feedback
- **TIGSource** -- veteran indie dev forum
- **GameDev.net** -- long-running dev community
- **Game Dev League Discord** -- active community

### Asset Sources

- **Kenney.nl** -- CC0 game assets
- **OpenGameArt.org** -- free game art and audio
- **Itch.io asset packs** -- indie asset marketplace
- **Sonniss GDC Bundles** -- free professional SFX
- **Freesound.org** -- community sound recordings

---

## Summary: Your Action Plan

Here is what you should do, in order:

1. **Make a tiny game first** (2-4 weeks) to learn Godot's workflow
2. **Define a 1-page GDD** for your medieval game -- one core mechanic, 3-4 learning outcomes
3. **Build a greybox prototype** in Godot -- if it is not fun with squares, it will not be fun with art
4. **Create a vertical slice** -- 60-90 seconds of polished gameplay
5. **Set up your repo** with proper Git, LFS, .gitignore, folder structure
6. **Start playtesting at week 3-4** -- with people who are not programmers
7. **Lock your art style** and pipeline by month 2
8. **Open an Itch.io page** with devlogs every 2-4 weeks
9. **Create a Steam page** 6-12 months before intended launch
10. **Participate in Steam Next Fest** with a playable demo
11. **Never add dark patterns** -- respect your players
12. **Polish relentlessly** -- the last 20% is what makes a game feel finished

> **"You do not finish games by adding time. You finish games by cutting content."**
> **Finish something. Then make it better. Then ship it.**
