# Documentation Conventions

> **Scope:** This document defines *where* documentation lives in the `docs/` tree. Every new document must be placed according to these rules so the repo stays navigable. (The rule that no file in the project should exist without being mentioned in some documentation lives in `module-workflow-and-docs.md`.)

## 1. `design/` vs `project/`

* **`docs/design/`** — Design and technical documents for **specific, concrete systems** (implemented *or* planned). One system per document: GDDs, TDDs, system specs. Examples: `ui-architecture-tdd.md`, `game-coordinator-module-tdd.md`, `character-integration-tdd.md`.
* **`docs/project/`** — **High-level project information that is *not* about a single system**: overall goals and philosophies, workflow guidelines, and technical *summaries* of the great code architecture. Examples: `architecture-overview.md`, `module-workflow-and-docs.md`, `design-decisions.md`, `asset-naming-conventions.md`.

**Rule of thumb:** If a document describes one system's internals → `design/`. If it is cross-cutting, a process, or an architecture *overview* → `project/`.

## 2. `plans/`

* **`docs/plans/`** — **Implementation plans**, especially those formulated by AI (phased build-out, migration steps, task breakdowns, sequencing of work). These are working plans: the *"how we will build it"* distinct from the *"what it is"* captured by the `design/` specs they implement.
* Even if a plan targets a single system, it lives here — not in `design/`. The `design/` TDD describes the system; the `plans/` doc describes the work order to get there.

## 3. Other `docs/` folders (reference)

* `docs/tech/` — engine, framework, and tooling specs (e.g., `technical-spec.md`).
* `docs/art/`, `docs/audio/` — style guides and pipelines.
* `docs/qa/` — testing plans and playtest frameworks.
