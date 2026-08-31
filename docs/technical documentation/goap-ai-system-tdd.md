# Technical Design Document (TDD) — GOAP AI System

## 1. Local Scene Tree Topography

```text
[CharacterBody3D (NPC Root)]
 ├── NavigationAgent3D
 ├── AnimationTree
 ├── ManagementPopulantComponent (Holds Network Node ID and Local References)
 ├── AIUtilityLayer (Node)       <-- [The Gateway / Cache Controller]
 └── GoapAgent (Node)            <-- [Plugin Core Controller Component]
     ├── Goals (Node)
     │    ├── SurviveGoal.gd
     │    └── CompleteLaborGoal.gd
     └── Actions (Node)
          ├── EatFoodAction.gd
          └── ChopWoodAction.gd

```

## 2. Component & Core Script Specifications

### 2.1 The AI Context Utility Layer (Level 2: Context)

```gdscript
# ai_utility_layer.gd
extends Node
class_name AIUtilityLayer

@onready var populant_component: ManagementPopulantComponent = $"../ManagementPopulantComponent"

# Caching Parameters to prevent mainframe data lag (CPU Killer Guardrail)
@export var cache_refresh_rate_frames: int = 20
var _fact_cache: Dictionary = {}
var _last_cached_frame: int = -999

## Primary entry point for local GOAP action scripts to fetch normalized assertions
func get_normalized_blackboard_facts() -> Dictionary:
    var active_frame = Engine.get_frames_drawn()
    if active_frame - _last_cached_frame < cache_refresh_rate_frames:
        return _fact_cache
        
    _fact_cache = _query_and_translate_world_state()
    _last_cached_frame = active_frame
    return _fact_cache

func _query_and_translate_world_state() -> Dictionary:
    var facts = {}
    var api = ServiceLocator.get_management_service()
    
    if not api:
        facts["fief_has_food"] = false
        facts["has_axe_tool"] = false
        facts["character_fatigue_normalized"] = 0.0
        facts["closest_woodland_coordinate"] = Vector3.ZERO
        return facts
        
    var node_id = populant_component.assigned_node_id
    var api_data: Dictionary = api.get_node_inspection_data(node_id)
    
    if api_data.is_empty():
        return facts

    # Convert continuous backend figures into strict conditional facts
    var total_provisions = api_data.get("berry_stock", 0) + api_data.get("meat_stock", 0)
    facts["fief_has_food"] = (total_provisions > 3)
    
    # Pass-through calculations matching current tool status flags
    facts["has_axe_tool"] = populant_component.equipment_inventory.has("lumber_axe")
    
    # Extract fatigue from local component tracking
    facts["character_fatigue_normalized"] = populant_component.fatigue_level # 0.0 to 1.0
    
    # Cache coordinates locally so get_cost() doesn't execute heavy distance checks natively
    facts["closest_woodland_coordinate"] = api.get_closest_resource_vector(node_id, "woodland")
    
    return facts

```

### 2.2 The Custom Dynamic Action Pool Scheduler (Level 1: Decision)

```gdscript
# goap_agent_controller.gd
extends Node

@onready var utility_layer: AIUtilityLayer = $"../AIUtilityLayer"
@onready var actions_container: Node = $Actions

## Assembles a culled configuration pool prior to executing the solver (Action Pruning)
func compile_pruned_action_array() -> Array:
    var api = ServiceLocator.get_management_service()
    var registered_actions = actions_container.get_children()
    
    if not api:
        return registered_actions 
        
    var p_id = $"../ManagementPopulantComponent".populant_id
    var authorized_categories: Array[String] = api.get_npc_assigned_labor_tags(p_id)
    
    var sanitized_pool = []
    for action in registered_actions:
        # Structural / Vital survival actions are exempt from pruning
        if not action.has_method("get_labor_classification_tag"):
            sanitized_pool.append(action)
            continue
            
        # Match labor tag explicitly against authorized system array entries
        var action_tag = action.get_labor_classification_tag()
        if action_tag in authorized_categories:
            sanitized_pool.append(action)
            
    return sanitized_pool

```

### 2.3 Integrated Work Action & Execution (Level 3: Execution)

```gdscript
# chop_wood_action.gd
extends "res://addons/goap/action.gd"

@export var base_cost: float = 20.0
var _cosmetic_timer: float = 0.0
# Cached reference to the reserved 3D tree node for this action's lifetime
var _target_node: Node3D = null

func get_labor_classification_tag() -> String:
    return "woodcutting"

func is_valid(agent_node: Node) -> bool:
    var utility = agent_node.get_node("AIUtilityLayer")
    var facts = utility.get_normalized_blackboard_facts()
    return facts.get("has_axe_tool", false)

func get_preconditions() -> Dictionary:
    return {"fief_needs_timber": true}

func get_effects() -> Dictionary:
    return {"fief_needs_timber": false}

## Dynamic Cost Weight Calculation Pass
func get_cost(agent_node: Node) -> float:
    var utility = agent_node.get_node("AIUtilityLayer")
    var facts = utility.get_normalized_blackboard_facts()
    
    var total_cost = base_cost
    
    # 1. Physical Friction (Optimized Squared Distance)
    var current_pos = agent_node.global_position
    var target_tree_pos = facts.get("closest_woodland_coordinate", current_pos)
    var distance_penalty = current_pos.distance_to_squared(target_tree_pos) * 0.01
    total_cost += distance_penalty
    
    # 2. Internal Friction (State Scaling)
    var fatigue = facts.get("character_fatigue_normalized", 0.0)
    if fatigue > 0.7:
        total_cost += 50.0 # Heavily penalize physical exertion if exhausted
        
    # 3. Absolute Mathematical Safety Guardrails
    return clamp(total_cost, 1.0, 200.0)

## Level 3 Processing Block: Running execution steps frame-by-frame
func perform(agent_node: Node, delta: float) -> bool:
    var navigation: NavigationAgent3D = agent_node.get_node("NavigationAgent3D")
    var anim_tree: AnimationTree = agent_node.get_node("AnimationTree")
    var utility = agent_node.get_node("AIUtilityLayer")
    var facts = utility.get_normalized_blackboard_facts()
    var reservations = ServiceLocator.get_reservation_service()
    
    # Step A: Acquire reservation on first perform() call
    # FIX 4: Request the reservation, then hand the target node reference back to the
    # agent. Without this handoff, agent_node.active_target_node stays null and the
    # heartbeat loop in _process() never fires, guaranteeing a lease timeout every run.
    if _target_node == null:
        var _target_pos = facts.get("closest_woodland_coordinate", agent_node.global_position)
        var api = ServiceLocator.get_management_service()
        _target_node = api.get_interactive_node_at_position(_target_pos)
        
        if _target_node:
            # Pass priority level (e.g., 1 for generic foraging)
            var success = reservations.request_slot_reservation(agent_node, _target_node, 1)
            if not success:
                _cleanup(agent_node)
                return false
            
            # FIX 4: Hand the target reference back to the agent for heartbeats!
            agent_node.active_target_node = _target_node
        else:
            return false
    
    # Step B: Spatial Steering Verification
    navigation.target_position = _target_node.global_position
    
    if not navigation.is_navigation_finished():
        var next_path_pos = navigation.get_next_path_position()
        var current_pos = agent_node.global_position
        var new_velocity = (next_path_pos - current_pos).normalized() * 3.0
        
        agent_node.velocity = new_velocity
        agent_node.move_and_slide()
        
        anim_tree.set("parameters/conditions/is_walking", true)
        anim_tree.set("parameters/conditions/is_chopping", false)
        return false # Action is still RUNNING
        
    # Step C: Aesthetic Interaction Sequence
    agent_node.velocity = Vector3.ZERO
    anim_tree.set("parameters/conditions/is_walking", false)
    anim_tree.set("parameters/conditions/is_chopping", true)
    
    _cosmetic_timer += delta
    if _cosmetic_timer >= 4.0: # Track a 4-second cosmetic animation loop
        _cosmetic_timer = 0.0
        anim_tree.set("parameters/conditions/is_chopping", false)
        _cleanup(agent_node)
        return true # Action completed with SUCCESS
        
    return false

## Releases reservation and clears agent's target reference on action end
func _cleanup(agent_node: Node) -> void:
    if _target_node:
        ServiceLocator.get_reservation_service().release_slot_reservation(agent_node, _target_node)
    agent_node.active_target_node = null
    _target_node = null
    _cosmetic_timer = 0.0

```