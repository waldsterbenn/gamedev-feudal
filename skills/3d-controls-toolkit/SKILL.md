---
name: 3d-controls-toolkit
description: Skill for using 3D Controls Toolkit in Godot game development.
license: Unknown
compatibility: Godot 4.x, Feudal Game project
metadata:
  repository: https://github.com/CiaNCI-Studio/3D-Controls-Toolkit
  maintainer: Cianci Studio
  version: 2.5 (Godot 4.5+)
  license: Unknown (repository doesn't specify)
tags:
- godot
- plugin
- feudal-game
---

# 3D Controls Toolkit
**Repository:** https://github.com/CiaNCI-Studio/3D-Controls-Toolkit
**Maintainer:** Cianci Studio
**Version:** 2.5 (Godot 4.5+)

### What It Is
A comprehensive 3D camera/controller plugin providing four distinct control schemes:
- First Person Controller
- Third Person Controller
- Side-Scrolling Controller
- Top-Down Controller

Designed as plug-and-play components that attach as children to `CharacterBody3D` nodes.

### How It Works
The plugin consists of five main GDScript classes inheriting from `Node`:
- `BaseControler3D.gd` – Base class with common functionality
- `FirstPersonControler3D.gd` – First-person perspective with mouse look
- `ThirdPersonControler3D.gd` – Third-person with orbit camera
- `SideScrollingControler3D.gd` – 2.5D side-scrolling movement
- `TopDownControler3D.gd` – Top-down/RTS-style movement

Each controller automatically handles player input, camera management, and basic movement physics when attached to a character node.

### Installation
1. Download the latest release or clone the repository
2. Copy the `addons/3d_controls_toolkit` folder to your project's `addons/` directory
3. Enable the plugin in Project Settings → Plugins
4. Configure required input map actions (see below)

### Configuration
**Required Input Actions:** `up`, `down`, `left`, `right`
**Optional Actions:** `sprint`, `jump`

**Key Configuration Properties:**
- **General:** Player geometry reference, movement type (Move and Slide/Collide/None)
- **Jump:** Height, time to peak/descend, variable jump, coyote time, jump buffer
- **Movement:** Walk/sprint speeds, acceleration/deceleration, dash, wall climb, double jump
- **First Person:** Mouse sensitivity, turn speed, camera angles, offsets
- **Third Person:** Spring length, camera angles, look-at offsets
- **Side-Scrolling:** Camera smoothing, boundary limits, look-at player
- **Top-Down:** Action type (keyboard vs mouse-click), floor detection, camera angle

### Usage Example
```gdscript
# Basic setup for a third-person character
# 1. Create a CharacterBody3D node
# 2. Add a MeshInstance3D for visualization
# 3. Add ThirdPersonControler3D as a child
# 4. Configure input actions in Project Settings

# The controller automatically handles:
# - WASD movement with camera-relative directions
# - Mouse-based camera orbiting
# - Jump mechanics (if configured)
# - Sprint/run transitions
```
