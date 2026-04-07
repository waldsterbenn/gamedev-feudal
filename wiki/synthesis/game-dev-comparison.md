---
type: synthesis
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/project/design-decisions.md
  - docs/project/indie-game-dev-guide.md
  - docs/project/asset-naming-conventions.md
tags:
  - analysis
  - comparison
  - synthesis
---

# Game Development: Engine & Process Comparison

## Engine Comparison

### Godot 4 vs Unity vs Unreal

| Aspect | Godot 4 | Unity | Unreal |
|--------|---------|-------|--------|
| **Cost** | Free, MIT license, no royalties | Free up to threshold, then revenue share | Free up to threshold, 5% royalty |
| **Learning Curve** | Gentle, GDScript is beginner-friendly | Moderate, C# required | Steep, C++ complexity |
| **2D Support** | Excellent, pixel-perfect rendering | Good via 2D tools | Basic, 3D-first engine |
| **Community Size** | Smaller but growing rapidly | Largest ecosystem | Large, AAA-focused |
| **Project Size** | Lightweight | Moderate to heavy | Heavy from the start |
| **Export Targets** | Win, Linux, macOS, WebGL (basic) | All major platforms | All major platforms |
| **Best For** | 2D indie, first-time devs | Cross-platform, large teams | 3D, AAA-quality graphics |

### Decision Rationale (ADR-001)

Godot 4 was selected because it aligns with:
- Team composition: first-time developers
- Budget: free/open source with no licensing complications
- Project scope: 2D casual educational game
- Technical approach: rapid prototyping and iteration

## Workflow Comparison: Software Engineering vs Game Development

### Key Differences

| Aspect | Software Engineering | Game Development |
|--------|---------------------|------------------|
| Requirements | Defined upfront | Emerge from [[Playtesting Framework|playtests]] |
| Architecture | Maintainable, extensible | Iterative, disposable |
| Testing | Unit-driven | Fun-driven, user-tested |
| Time Effort | 90% code, 10% assets | ~30% code, ~30% content, ~40% polish |
| Sprint Goals | Feature completion | Discovery and refinement |

### Adapted Process

The project uses a **hybrid approach**:
- Agile/kanban for asset pipeline and bug tracking
- Iterative, time-boxed prototyping for game design
- Dynamic 1-page GDD that evolves with code proof
- Weekly playable deliverables instead of feature-complete sprints

## Art Pipeline Comparison

| Style | Pros | Cons | Verdict for Project |
|---|---|---|---|
| Pixel Art | High control, natural for 2D casual, massive tool support | Frame-by-frame animation is slow | **Best choice** for medieval theme |
| Low-Poly 3D | Skeletal animation, lighting does heavy lifting | Requires Blender skills | Good if team wants 3D |
| Vector Art | Resolution-independent | Tends to look corporate/mobile-style | Not ideal for medieval |
| 2D Hand-Drawn | Visually stunning | Extremely labor-intensive | Avoid unless outsourced |

## See Also

- [[Technical Choices]]
- [[Design Decisions]]
- [[Asset Naming Conventions]]
- [[Indie Game Development Process]]
- [[QA Strategy]]
