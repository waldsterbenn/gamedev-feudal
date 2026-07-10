# Game Design Document (GDD) — GOAP AI Architecture

## 1. Architectural Philosophy & Intent

### 1.1 Aesthetic Labor vs. Authoritative Ledger

The core gameplay loops of *Wilderness Fief* rely on an intentional, strict decoupling of simulation mechanics and physical character visuals.

* **Cosmetic Work Actions:** NPC behavioral execution loops (such as swinging an axe at a tree trunk or hoeing dirt) are **purely cosmetic**. The AI handles the spatial representation of work, animations, steering, and pathing.
* **The Background Ledger:** The `ManagementModule` holds absolute authority over the actual logistics. The physical yield calculation, resource extraction updates, and daily material transformations occur inside the headless backend ledger at fixed tick intervals, independent of whether an individual NPC completed their swinging animation loop.

> **Design Note:** It might be tempting to let the GOAP planner take care of *"If I don't have a knife, I can't whittle,"* but keeping that limitation in the management module or the inventory module keeps the AI workload much smaller. It also makes it easier to get an overview of the elements and rules of those systems. Making the management dependent on the AI to enforce a "no tool, no work" rule creates a sort of dangling logic that is not immediately obvious when looking at the management module itself.

### 1.2 Tool-Gated Prerequisites & Assignment Permissions

An agent cannot evaluate or start any labor loop unless they physically possess the relevant instrumentation within their immediate local inventory parameters. Furthermore, actions are aggressively culled beforehand by the `ManagementModule` using a **Dynamic Action Pool** pattern.

* **Job Filtering:** If a Populant is not designated as a lumberjack within the management interface, the `ChopWood` action is entirely stripped from their choice configuration pool before graph solving begins.
* **Permanent Actions:** Non-work tasks (such as `Eat`, `Sleep`, or `Wander`) are permanent and escape structural filtration.

The core rule for evaluating action availability is defined as:

$$\text{Action Viability} = \text{Assigned Job Tag} \land \text{Tool Inventory Flag}$$

### 1.3 Interrupt-Driven Planning Mechanics

To prevent major CPU stutters, agents do not run their $A^*$ path planning algorithm on every tick frame. Planning is **on-demand** and triggers only when:

1. The currently active action sequence runs to absolute completion.
2. The active action reports an execution failure (e.g., target resource node deleted or blocked).
3. The local `AIUtilityLayer` intercepts an urgent systemic status flag (e.g., immediate starvation danger).

---

## 2. Dynamic Action Cost & Weighting Framework

To achieve organic, emergent behavior, action costs are calculated dynamically rather than using hardcoded integers. The calculation follows a strict project-wide boundary box ($\text{Cost Range: } 1 \le \text{Cost} \le 200$) and adheres to a standardized formula:

$$\text{Total Cost} = \text{Base Cost} + \text{Physical Friction} + \text{Internal Friction}$$

### Breakdown of Cost Variables

| Variable | Description |
| --- | --- |
| **Base Cost** | The foundational developer preference rating (lower values denote higher inherent baseline priority). |
| **Physical Friction** | Distance Penalty. Calculated using cheap squared-distance math (`distance_to_squared()`) to penalize distant tasks without triggering heavy square-root operations. |
| **Internal Friction** | Trait/State Penalty. Weights values based on character characteristics, exhaustion levels, or localized status flags. |