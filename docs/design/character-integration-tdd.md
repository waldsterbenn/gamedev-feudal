# Technical Design Document (TDD) — Character & Scene Integration

## 1. Architectural Position
This document defines how the physical 3D world (the `NPC` scene) and the background economic simulation (the `Management Module`) are connected. A single bridge component inside the NPC scene is the only point of contact between the two domains.

## 2. Character Hierarchy Definitions

* **NPC:** The comprehensive, unified 3D engine GameObject scene instance. It handles physical navigation (`NavigationAgent3D`), visual mesh animations, audio, and independent module component attachments.
* **Populant:** The economic representation of an individual inside the management ledger. A Populant possesses no spatial footprint; they exist purely as a profile tracked by the data layers.

## 3. The Component Bridge

The connection between the physical world and the background simulation is managed via the `ManagementPopulantComponent` attached directly inside the NPC gameobject scene.

* **The AI Translation Layer:** The standalone Goal-Oriented Action Planner (GOAP) inside the NPC scene continuously reads its own local `ManagementPopulantComponent`.
* **Orchestrating Movement:** When the control layer updates the component's data fields (such as changing its residency node or job type), the GOAP brain registers a mismatch between its current 3D position and its designated economic role. The brain then generates physical navigation tasks, commanding the NPC to march across the `Terrain3D` map to locate the appropriate physical markers matching its new data state.
