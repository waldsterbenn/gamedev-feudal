---
name: beehave-behavior-trees
description: A node-based behavior tree implementation for Godot, allowing visual
  AI behavior design within the scene tree with dedicated debugging tools.
license: MIT (assumed)
compatibility: Godot 4.x, Feudal Game project
metadata:
  repository: https://github.com/bitbrain/beehave
  maintainer: bitbrain
  version: 2.x (Godot 4.x), 1.x (Godot 3.x)
  license: MIT (assumed)
  documentation: https://github.com/bitbrain/beehave/wiki
tags:
- godot
- plugin
- feudal-game
---

# Beehave (Behavior Trees)
**Repository:** https://github.com/bitbrain/beehave
**Documentation:** https://github.com/bitbrain/beehave/wiki
**Maintainer:** bitbrain
**Version:** 2.x (Godot 4.x), 1.x (Godot 3.x)
**License:** MIT (assumed)

### What It Is
A node-based behavior tree implementation for Godot, allowing visual AI behavior design within the scene tree with dedicated debugging tools.

### Architecture
- **Behavior Tree Root:** `BeehaveTree` node managing tree execution
- **Composite Nodes:** Sequence, Selector, Parallel, Random
- **Decorator Nodes:** Inverter, Succeeder, Repeater, UntilFail
- **Action Nodes:** Custom GDScript actions
- **Condition Nodes:** Boolean checks for transitions
- **Blackboard:** Shared memory for behavior tree nodes

### Installation
1. Download latest release for your Godot version:
- Godot 4.x → beehave 2.x branch
- Godot 3.x → beehave 1.x branch
2. Unpack `addons/beehave` folder to project
3. Enable plugin in Project Settings → Plugins
4. Copy `script_templates` to project root (optional)

### Version Compatibility
| Godot Version | Beehave Branch | Beehave Version |
|---------------|----------------|-----------------|
| 3.x           | 3.x            | 1.x             |
| 4.x           | 4.x            | 2.x             |
| 4.5+          | 4.x            | 2.10+           |
| 4.1.x         | 4.x            | 2.9.x           |
| 4.0.x         | 4.x            | 2.7.x           |

### Basic Behavior Tree
```gdscript
# Example: Enemy AI behavior tree
# Tree structure:
# - Selector (try in order):
#   - Sequence (Attack if in range):
#     - Condition: IsTargetInRange
#     - Action: AttackTarget
#   - Sequence (Chase target):
#     - Condition: HasTarget
#     - Action: MoveToTarget
#   - Action: WanderIdle

extends BeehaveTree

func _ready():
# Create tree nodes programmatically
var root = Selector.new()
add_child(root)

var attack_sequence = Sequence.new()
root.add_child(attack_sequence)

var range_condition = Condition.new()
range_condition.script = preload("res://scripts/conditions/is_target_in_range.gd")
attack_sequence.add_child(range_condition)

var attack_action = Action.new()
attack_action.script = preload("res://scripts/actions/attack_target.gd")
attack_sequence.add_child(attack_action)

# ... additional branches
```

### Visual Editor Integration
1. Add `BeehaveTree` node to scene
2. Add behavior nodes as children
3. Connect nodes in editor (parent-child relationships)
4. Assign custom scripts to Action/Condition nodes
5. Use Debug view to monitor tree execution

### Custom Action Implementation
```gdscript
# res://scripts/actions/move_to_target.gd
extends "res://addons/beehave/actions/Action.gd"

class_name MoveToTargetAction

@export var speed: float = 100.0
@export var arrival_distance: float = 10.0

func action_tick(actor: Node, blackboard: Blackboard) -> int:
var target = blackboard.get_value("target")
if not target:
return FAILURE

var direction = (target.global_position - actor.global_position).normalized()
actor.velocity = direction * speed
actor.move_and_slide()

if actor.global_position.distance_to(target.global_position) <= arrival_distance:
return SUCCESS

return RUNNING
```

### Blackboard Usage
```gdscript
# Setting blackboard values
blackboard.set_value("target", player)
blackboard.set_value("last_known_position", player.global_position)
blackboard.set_value("health", current_health)

# Reading in conditions/actions
var target = blackboard.get_value("target")
var health = blackboard.get_value("health", 100)
```

### Debugging Features
- **Runtime Debug View:** Monitor active nodes in editor
- **Performance Monitoring:** Track tree execution time
- **Visual Status Indicators:** Color-coded node states
- **Breakpoints:** Pause tree execution for inspection

### Integration Patterns
- **State Machines:** Use behavior trees for AI decision making
- **Animation Control:** Connect behavior states to animation tree
- **Sensor Systems:** Update blackboard with perception data
- **Utility AI:** Combine with scoring systems for complex decisions
