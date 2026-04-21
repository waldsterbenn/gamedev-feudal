---
name: navigation-region3d
description: Godot's built-in 3D navigation system for AI pathfinding, consisting
  of:.
license: Unknown
compatibility: Godot 4.x, Feudal Game project
metadata:
  documentation: https://docs.godotengine.org/en/stable/classes/class_navigationregion3d.html
tags:
- godot
- plugin
- feudal-game
---

# NavigationRegion3D & NavigationMesh (Built-in Godot)
**Documentation:** https://docs.godotengine.org/en/stable/classes/class_navigationregion3d.html

### What It Is
Godot's built-in 3D navigation system for AI pathfinding, consisting of:
- `NavigationRegion3D`: Defines navigable areas
- `NavigationMesh`: Geometry defining walkable surfaces
- `NavigationAgent3D`: AI controller for path following
- `NavigationServer3D`: Backend server managing all navigation data

### How It Works
1. **Baking:** Convert scene geometry into navigation mesh (convex polygon soup)
2. **Querying:** AI agents request paths between points on the navmesh
3. **Steering:** Agents follow paths with obstacle avoidance
4. **Dynamic Updates:** Navmesh can be updated at runtime for destructible environments

### Installation
Built into Godot 4.x – no installation required.

### Basic Setup
```gdscript
# 1. Create NavigationRegion3D node
# 2. Add NavigationMesh resource
# 3. Bake navmesh from scene geometry
# 4. Add NavigationAgent3D to AI characters

# Programmatic baking example
var nav_region = $NavigationRegion3D
var nav_mesh = NavigationMesh.new()
nav_mesh.cell_size = 0.2
nav_mesh.cell_height = 0.2
nav_mesh.agent_radius = 0.5
nav_mesh.agent_height = 2.0
nav_mesh.agent_max_climb = 0.8
nav_mesh.agent_max_slope = 45.0

nav_region.navigation_mesh = nav_mesh
nav_region.bake_navigation_mesh()

# AI agent usage
var agent = NavigationAgent3D.new()
agent.target_desired_distance = 0.5
agent.path_desired_distance = 0.5
agent.target_position = target_position

func _physics_process(delta):
if agent.is_navigation_finished():
return

var next_path_position = agent.get_next_path_position()
var direction = global_position.direction_to(next_path_position)
velocity = direction * speed
move_and_slide()
```

### Advanced Features
- **Navigation Layers:** Separate navmeshes for different agent types
- **Navigation Links:** Jump pads, ladders, teleports
- **Obstacle Avoidance:** Dynamic obstacle avoidance using RVO
- **Crowd Simulation:** Groups of agents with collective avoidance
- **Performance:** Multi-threaded pathfinding queries

### Best Practices
1. Use primitive colliders (box, sphere, capsule) for dynamic objects
2. Bake static geometry once, update dynamically for moving platforms
3. Use navigation layers to separate ground/flying/water units
4. Implement path smoothing for natural movement
5. Cache path queries for frequently used routes
