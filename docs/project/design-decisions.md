# Design Decision Log (ADRs)

> **Purpose:** Capture every significant decision we make, why we made it, and what alternatives we considered. When someone joins the team later -- or when we forget our own reasoning -- this document is the source of truth.
> **Format:** Architecture Decision Records -- lightweight, one entry per decision.

---

## How to Use This

When the team makes a decision (chooses Godot over Unity, picks a camera perspective, commits to a combat style):

1. Create a new entry with the next number
2. Write the decision, the context (why), and the consequences (what it means)
3. List alternatives that were considered but rejected
4. Link to any supporting documents (questionnaire answers, prototypes, research)

**Do not** use this for minor details (button colors, variable names). Use it for design and technical choices that would be expensive to reverse later.

---

## Format

### ADR-NNN: Short Title

- **Date:** YYYY-MM-DD
- **Status:** Proposed | Accepted | Deprecated | Superseded
- **Category:** Engine | Design | Art | Audio | Technical | Process

**Context:** What prompted this decision? What problem are we solving?

**Decision:** What did we decide?

**Consequences:** What does this mean for the project? What does it lock us into or out of?

**Alternatives Considered:** What else did we look at, and why was it rejected?

**References:** Links to related docs, prototypes, or discussions.

---

## Decisions

### ADR-001: Use Godot 4.6 as the Game Engine

- **Date:** 2026-04-05
- **Status:** Superseded by ADR-004 (engine baseline moved to Godot 4.7, 2026-09-02)
- **Category:** Engine

**Context:** Need a game engine for a feudal-themed game. Team includes first-time developers. Requirements: free/open source, gentle learning curve, good 2D support, no licensing complications.

**Decision:** Use Godot 4.x with GDScript as the primary scripting language. GDExtension with C++ available if performance requires it.

**Consequences:**
- Engine is free with no royalties ever
- GDScript is easier for beginners than C# or C++
- Smaller community than Unity/Unreal, so fewer third-party tutorials -- but growing fast
- Godot's node/scene model requires learning its architecture (but it's intuitive once understood)
- Export targets: Windows, Linux, macOS supported. WebGL and console ports less mature.

**Alternatives Considered:**
- Unity -- larger ecosystem, but C# steeper learning curve, licensing changes introduced uncertainty, heavier footprint
- Unreal -- powerful but overkill for this scope, C++ is significant learning curve, project sizes are large from the start

**References:**
- `docs/tech/technical-spec.md` -- full technical specification

---

### ADR-002: Use Markdown for All Project Documentation

- **Date:** 2026-04-05
- **Status:** Accepted
- **Category:** Process

**Context:** Need a documentation system accessible to all team members, version-controllable, and easy to edit without special software.

**Decision:** All project documentation is written in Markdown (.md) and stored in the `docs/` directory.

**Consequences:**
- Docs are in Git -- version history, diffs, and branch-specific versions for free
- Readable in any text editor, GitHub, or Markdown viewer
- No special tools needed to write docs
- Not suitable for complex visual diagrams -- use Excalidraw files or image references

**Alternatives Considered:**
- Google Docs / Notion -- easier collaboration, but not version-controlled and not alongside code
- Wiki (GitHub Wiki) -- version controlled but harder to manage alongside the main repo

**References:**
- `docs/README.md` — documentation structure overview

---

### ADR-003: Trunk-Based Development

- **Date:** 2026-09-02
- **Status:** Accepted
- **Category:** Process

**Context:** The project started with a "vertical slices" workflow — each experiment lived in its own `src/slice_<name>/` Godot project, then got migrated into `src/feudal-age/` after validation. In practice the slices became throwaway duplicates (three slice dirs converged on the same addons and assets), integration cost was high, and the "migrate after stable" step rarely happened — validated code stayed stranded in slice directories while `src/feudal-age/` lagged.

**Decision:** Adopt trunk-based development. All code lives in `src/feudal-age/` on `master` (the trunk). Feature work happens on short-lived branches merged to master via PR; master must always pass the two-stage headless gate (cache-warm + `--headless --quit`). The `src/slice_*` workflow is retired — see wayfinder ticket "Trunk-based workflow — retire slice dirs/branches, update agent docs".

**Consequences:**
- No more duplicated addons/assets across slice dirs; one canonical Godot project.
- Master is always deployable; the headless gate is the definition of "green".
- Experimentation happens on branches rather than in parallel projects; prototype code must be either merged or deleted — no stranded middle state.
- The "vertical slice" concept (thin end-to-end proof of a loop) remains a design/QA tool — as a milestone, not a directory layout.

**Alternatives Considered:**
- Keep the slice workflow but add mandatory migration — rejected: the migration step was the part that kept failing; process-only fixes don't stick.
- Long-lived feature branches — rejected: single-developer project; short-lived branches + trunk keeps master green without merge hell.

**References:**
- Wayfinder map [#45](https://github.com/waldsterbenn/gamedev-feudal/issues/45) and ticket "Trunk-based workflow — retire slice dirs/branches, update agent docs"

---

### ADR-004: Godot 4.7 as the Engine Baseline

- **Date:** 2026-09-02
- **Status:** Accepted
- **Category:** Engine

**Context:** ADR-001 chose Godot 4.6 and the project was set up on 4.6.2, but the toolchain has since moved to **Godot 4.7.2** (installed, running). The 4.7 editor rewrites `config/features` to `"4.7"` on every save and its FBX importer adds new mesh options (observed as a one-time `.import` regeneration), so the committed metadata and documentation — which still said 4.6 — no longer matched the engine actually in use.

**Decision:** The engine baseline is **Godot 4.7.x** (installed: 4.7.2). `project.godot` declares features `"4.7"`; all live documentation states Godot 4.7; 4.6-era research documents are kept as historical reference with staleness banners rather than re-run.

**Consequences:**
- Import metadata and the feature flag now match the running engine — no more editor-driven churn.
- Plugin compatibility is judged against 4.7 (3D Controls Toolkit and Terrain3D verified running in-tree).
- Future research, skill compatibility notes, and setup docs target 4.7.

**Alternatives Considered:**
- Stay on 4.6 — rejected: the project already runs 4.7.2 and the editor keeps bumping the feature flag; fighting the toolchain is churn without benefit.
- Re-run all 4.6-era research — rejected: the research is API-conservative and mostly valid; flagging it as historical is cheaper and honest.

**References:**
- ADR-001 (superseded), PR [#59](https://github.com/waldsterbenn/gamedev-feudal/pull/59), `docs/research/godot-4.6-*.md` (historical)

---

<!-- Add new decisions below this line -->
