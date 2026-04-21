---
name: godot-steering-ai
description: A steering behavior framework inspired by GDX-AI, providing modular AI
  movement behaviors separate from Godot's built-in navigation system.
license: MIT (assumed)
compatibility: Godot 4.x, Feudal Game project
metadata:
  repository: Likely https://github.com/GDQuest/godot-steering-ai-framework
  maintainer: GDQuest
  version: Godot 3.x (3+ years outdated)
  license: MIT (assumed)
  documentation: https://gdquest.gitbook.io/godot-3-steering-ai-framework-reference
tags:
- godot
- plugin
- feudal-game
---

# Godot Steering AI Framework
**Documentation:** https://gdquest.gitbook.io/godot-3-steering-ai-framework-reference
**Repository:** Likely https://github.com/GDQuest/godot-steering-ai-framework
**Maintainer:** GDQuest
**Version:** Godot 3.x (3+ years outdated)
**License:** MIT (assumed)

### What It Is
A steering behavior framework inspired by GDX-AI, providing modular AI movement behaviors separate from Godot's built-in navigation system.

### Architecture
- **GSAISteeringAgent:** Base agent class storing position, orientation, velocity
- **GSAISteeringBehavior:** Individual behaviors (seek, flee, pursue, wander, etc.)
- **GSAIBlend:** Behavior blending with weights
- **GSAIPriority:** Behavior prioritization (first non-zero acceleration wins)
- **GSAIProximity:** Neighborhood detection for group behaviors

### Installation
1. Download from GitHub releases
2. Copy `addons/com.gdquest.godot-steering-ai-framework` to project
3. Place in organized directory (e.g., `res://src/libraries/`)
4. Godot auto-registers all `GSAI*` classes

### Core Behaviors
- **Seek/Flee:** Move toward/away from target
- **Pursue/Evade:** Predictive chasing/escaping
- **Arrive:** Decelerate to stop at target
- **Wander:** Random exploration
- **FollowPath:** Waypoint following
- **AvoidCollisions:** Obstacle avoidance
- **Flock:** Group behaviors (separation, alignment, cohesion)

### Complete Example (from documentation)
```gdscript
extends KinematicBody2D

export var speed_max := 450.0
export var acceleration_max := 50.0
export var angular_speed_max := 240
export var angular_acceleration_max := 40
export var health_max := 100
export var flee_health_threshold := 20

var velocity := Vector2.ZERO
var angular_velocity := 0.0
var linear_drag := 0.1
var angular_drag := 0.1
var acceleration := GSAITargetAcceleration.new()

onready var current_health := health_max
onready var agent := GSAISteeringAgent.new()
onready var player: Node = get_tree().get_nodes_in_group("Player")[0]
onready var player_agent: GSAISteeringAgent = player.agent
onready var proximity := GSAIRadiusProximity.new(agent, [player_agent], 100)
onready var flee_blend := GSAIBlend.new(agent)
onready var pursue_blend := GSAIBlend.new(agent)
onready var priority := GSAIPriority.new(agent)

func _ready() -> void:
# Agent configuration
agent.linear_speed_max = speed_max
agent.linear_acceleration_max = acceleration_max
agent.angular_speed_max = deg2rad(angular_speed_max)
agent.angular_acceleration_max = deg2rad(angular_acceleration_max)
agent.bounding_radius = calculate_radius($CollisionPolygon2D.polygon)
update_agent()

# Behavior setup
var pursue := GSAIPursue.new(agent, player_agent)
pursue.predict_time_max = 1.5

var flee := GSAIFlee.new(agent, player_agent)
var avoid := GSAIAvoidCollisions.new(agent, proximity)
var face := GSAIFace.new(agent, player_agent)
face.alignment_tolerance = deg2rad(5)
face.deceleration_radius = deg2rad(60)

var look := GSAILookWhereYouGo.new(agent)
look.alignment_tolerance = deg2rad(5)
look.deceleration_radius = deg2rad(60)

flee_blend.is_enabled = false
flee_blend.add(look, 1)
flee_blend.add(flee, 1)

pursue_blend.add(face, 1)
pursue_blend.add(pursue, 1)

priority.add(avoid)
priority.add(flee_blend)
priority.add(pursue_blend)

func _physics_process(delta: float) -> void:
update_agent()

if current_health <= flee_health_threshold:
pursue_blend.is_enabled = false
flee_blend.is_enabled = true

priority.calculate_steering(acceleration)

velocity = (velocity + Vector2(acceleration.linear.x, acceleration.linear.y) * delta).clamped(agent.linear_speed_max)
velocity = velocity.linear_interpolate(Vector2.ZERO, linear_drag)
velocity = move_and_slide(velocity)

angular_velocity = clamp(angular_velocity + acceleration.angular * delta, -agent.angular_speed_max, agent.angular_speed_max)
angular_velocity = lerp(angular_velocity, 0, angular_drag)
rotation += angular_velocity * delta

func update_agent() -> void:
agent.position.x = global_position.x
agent.position.y = global_position.y
agent.orientation = rotation
agent.linear_velocity.x = velocity.x
agent.linear_velocity.y = velocity.y
agent.angular_velocity = angular_velocity

func calculate_radius(polygon: PoolVector2Array) -> float:
var furthest_point := Vector2(-INF, -INF)
for p in polygon:
if abs(p.x) > furthest_point.x:
furthest_point.x = p.x
if abs(p.y) > furthest_point.y:
furthest_point.y = p.y
return furthest_point.length()

func damage(amount: int) -> void:
current_health -= amount
if current_health <= 0:
queue_free()
```

### Integration with Godot Navigation
Steering behaviors can complement Godot's navigation system:
- Use NavigationAgent3D for global pathfinding
- Use GSAI for local obstacle avoidance and flocking
- Blend behaviors for natural movement
