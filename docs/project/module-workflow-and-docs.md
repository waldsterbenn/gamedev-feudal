# Module Workflow & Documentation Standard

> **Scope:** This is the project-level standard for how new simulation modules are designed, translated into technical design, and documented. It is the canonical home for workflow and terminology conventions that apply *across* every module. Per-module terminology lives in each module's own documentation; global terminology is defined here and does not need to be redefined per module.

## 1. Workflow for Adding a New Module

As widely as possible, try to keep the game separated into self-contained modules. When creating a new module, use this approach:

### 1.1 Game Design Document
Try to describe what the module simulates **without** getting technical.
* What does the player experience?
* What do you think is happening behind the scenes?

### 1.2 Define the Domain Objects (abstract)
Try to define abstract objects and rules from the Game Design Document:
* **Entities** — Objects that have a unique identity that persists over time, even if their attributes change.
* **Value Objects** — Objects that have no identity; they are defined solely by their attributes. If two Value Objects have the same values, they are identical.
* **Aggregates** — A cluster of associated Domain Objects that we treat as a single unit for data changes.

### 1.3 Translate the Domain to a Technical Design
* What data and algorithms are needed?
* Define classes, functions.
* Define what scripts the classes need to be separated into.
* You can start defining what Godot nodes will be needed as well, since they are sometimes worked with directly in scripts.
* Remember the **"Data up, Signals down"** Rule (see `architecture-overview.md`).
* **Map domain "Aggregates" to Custom Resources Early.** In Godot, you should immediately write these as Custom Resources (`extends Resource`). For example, by keeping your inventory logic in a pure `Resource`, your UI Node and your Player Physics Node can both look at the same `Resource` without having to talk directly to each other. This keeps modules separated.

### 1.4 Define the Godot Implementation
* **What nodes will be needed, what are their types?** (`MeshInstance3D`, `Sprite2D`, `CollisionShape3D`, `CharacterBody3D`, …)
* **What scripts?** (`Resource`?)
* **Scene hierarchy:**
  * Does the design need new scenes? (e.g., a physical resource pile, or a "manager"/"controller" type scene that can generate/spawn new game objects into the world.)
  * Changes to existing nodes? (e.g., does it need to add a "component" node to existing scenes, like adding a health node to the NPC scene?)
* **What folders do the files belong in?** Put scripts in their own subfolder in the script folder. The project documentation should be able to tell you what goes where. For where the *documentation itself* lives, see `documentation-conventions.md` (`design/` vs `project/`, and `docs/plans/` for implementation plans).
* **Where do the new scenes need to sit in the game world hierarchy to do their thing?**
  * Is it a global "manager" scene that attaches straight to the top of the "root"/"world" scene? (Like an enemy spawner, for example.)
  * Will there be multiple instances of this scene? (Like an enemy type of which there need to be many.)
  * Will we need to organize these in the hierarchy somehow?
* **How do they enter the world hierarchy?**
  * Are they placed there by a designer before the game is even compiled or run?
  * Are they spawned dynamically at runtime? (e.g., does the game need to spawn in fresh workers as the player's settlement grows?)
  * If so, read the chapter about **Coordinators** (see `coordinator-pattern.md`).

## 2. Module Documentation Template

### 2.1 Terminology
* Terms specific to this module.
* Terminology that is global for the whole project is defined in the project documentation (this doc) and does not need to be included in the module documentation.

### 2.2 Domain Objects
A chapter for each domain object, with sub-chapters about the individual technical pieces, like:
* **Scripts** (a sub-chapter for each script): scripts that represent this domain object and drive its behavior.
  * Each class.
  * Each variable, public and private.
  * Each function, both public and private.
  * Any algorithms and patterns used.
* **Resource Class** (a sub-chapter for each `Resource`).

### 2.3 Scene / Node Hierarchy
A sub-chapter for each Scene:
* Godot nodes representing this domain object.

> In general: no files should exist in the project that are not mentioned in some piece of documentation somewhere.

### 2.4 Systems
* Describe "cross-script" processes.
* Describe where components from this system fit into other systems if relevant (e.g., overlap with the GOAP AI).

### 2.5 APIs
What APIs does this module expose for other modules or the greater game architecture?
