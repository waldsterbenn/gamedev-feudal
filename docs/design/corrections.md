Scanning the implementation from Part 13 reveals **three critical issues**—ranging from Godot 4 API quirks to logic desynchronization—that would cause bugs or silent memory leaks during runtime.

Here is the breakdown of the bugs and how to fix them.

### Bug 2: Godot 4 `Callable.bind()` Memory Leak

**The Issue:** In Godot 4, calling `_on_agent_unexpected_destruction.bind(agent, target)` generates a *brand new Callable object* in memory every time it is evaluated. Because of this, the check `is_connected(callable)` will always return false, and `disconnect(callable)` will fail. This causes the signal to connect multiple times, creating a massive memory leak.
**The Fix:** Remove the signal connections entirely. Since we are already sweeping slots on the tactical tick (1.0 Hz) and using `WeakRef`, we can just let the system passively auto-clean any slot where `weakref.get_ref() == null`.

### Bug 3: Eviction State Leak

**The Issue:** When a high-priority agent evicts a low-priority agent, the code overwrote the `occupying_agent_weakref` but never explicitly cleared the old agent's data or signal connections, leaving ghost data floating in the service.
**The Fix:** Call `_clear_slot()` on the evicted agent *before* assigning it to the new high-priority agent.

### Bug 4: Missing Variable Handoff (GOAP to Agent)

**The Issue:** The AI action (`chop_wood_action.gd`) successfully requested the reservation, but it never handed the target node back to the NPC's main script (`spatial_npc_agent.gd`). As a result, the NPC's heartbeat loop (`_process`) was checking a null variable and never actually sent the heartbeat ping, guaranteeing a timeout every time.

---

### The Corrected Implementations

#### 1. The Fixed Reservation Service

This updated service removes the buggy signal bindings and relies entirely on passive, secure garbage collection via real-world timing.

```gdscript
# reservation_service.gd
extends Node

const LAYER_AVAILABLE: int = 5
const LAYER_RESERVED: int = 6
const LEASE_TTL_REAL_SECONDS: float = 15.0

func _ready() -> void:
	TimeEngine.game_tick_passed.connect(_on_tactical_clock_tick)

func initialize_reservation_slots(target: Node3D, slot_count: int, offsets: Array[Vector3] = []) -> void:
	var slots: Array[ReservationSlot] = []
	for i in range(slot_count):
		var slot = ReservationSlot.new()
		if i < offsets.size():
			slot.local_offset = offsets[i]
		slots.append(slot)
	target.set_meta("reservation_slots", slots)
	
	target.set_collision_layer_value(LAYER_AVAILABLE, true)
	target.set_collision_layer_value(LAYER_RESERVED, false)

func request_slot_reservation(agent: Node3D, target: Node3D, priority: int) -> bool:
	if not is_instance_valid(agent) or not is_instance_valid(target) or not target.has_meta("reservation_slots"):
		return false
		
	var slots: Array = target.get_meta("reservation_slots")
	var best_eviction_target: ReservationSlot = null
	var lowest_active_priority: int = INF
	
	for slot in slots:
		var holder = slot.occupying_agent_weakref.get_ref() if slot.occupying_agent_weakref else null
		
		if holder == null:
			_assign_slot_lease(agent, slot, target, priority)
			return true
			
		if slot.current_priority < lowest_active_priority:
			lowest_active_priority = slot.current_priority
			best_eviction_target = slot

	if priority > lowest_active_priority and best_eviction_target != null:
		var evicted_agent = best_eviction_target.occupying_agent_weakref.get_ref()
		
		# FIX 3: Explicitly clear the evicted agent first
		_clear_slot(best_eviction_target) 
		
		if evicted_agent and evicted_agent.has_method("on_reservation_evicted"):
			evicted_agent.on_reservation_evicted()
			
		_assign_slot_lease(agent, best_eviction_target, target, priority)
		return true
		
	return false

func refresh_lease_heartbeat(agent: Node3D, target: Node3D) -> void:
	if not is_instance_valid(target) or not target.has_meta("reservation_slots"):
		return
	var slots: Array = target.get_meta("reservation_slots")
	for slot in slots:
		if slot.occupying_agent_weakref and slot.occupying_agent_weakref.get_ref() == agent:
			# FIX 1: Use absolute machine time, not in-game simulated time
			slot.lease_expiry_time = (Time.get_ticks_msec() / 1000.0) + LEASE_TTL_REAL_SECONDS
			return

func release_slot_reservation(agent: Node3D, target: Node3D) -> void:
	if not is_instance_valid(target) or not target.has_meta("reservation_slots"):
		return
		
	var slots: Array = target.get_meta("reservation_slots")
	var all_slots_free: bool = true
	
	for slot in slots:
		if slot.occupying_agent_weakref and slot.occupying_agent_weakref.get_ref() == agent:
			_clear_slot(slot)
		elif slot.occupying_agent_weakref and slot.occupying_agent_weakref.get_ref() != null:
			all_slots_free = false
			
	if all_slots_free:
		target.set_collision_layer_value(LAYER_AVAILABLE, true)
		target.set_collision_layer_value(LAYER_RESERVED, false)

func _assign_slot_lease(agent: Node3D, slot: ReservationSlot, target: Node3D, priority: int) -> void:
	slot.occupying_agent_weakref = weakref(agent)
	slot.current_priority = priority
	slot.lease_expiry_time = (Time.get_ticks_msec() / 1000.0) + LEASE_TTL_REAL_SECONDS
	_update_target_collision_state(target)

# FIX 2: Removed buggy Godot 4 Signal bindings entirely
func _clear_slot(slot: ReservationSlot) -> void:
	slot.occupying_agent_weakref = null
	slot.current_priority = 0
	slot.lease_expiry_time = 0.0

func _update_target_collision_state(target: Node3D) -> void:
	var slots: Array = target.get_meta("reservation_slots")
	var fully_allocated: bool = true
	for slot in slots:
		if slot.occupying_agent_weakref == null or slot.occupying_agent_weakref.get_ref() == null:
			fully_allocated = false
			break
			
	if fully_allocated:
		target.set_collision_layer_value(LAYER_AVAILABLE, false)
		target.set_collision_layer_value(LAYER_RESERVED, true)

func _on_tactical_clock_tick() -> void:
	# FIX 1: Use machine time
	var current_real_time = Time.get_ticks_msec() / 1000.0 
	var active_targets = get_tree().get_nodes_in_group("interactive_objects")
	
	for target in active_targets:
		if not target.has_meta("reservation_slots"): continue
		var slots: Array = target.get_meta("reservation_slots")
		
		for slot in slots:
			# FIX 2: Passive garbage collection! If the agent was deleted, .get_ref() returns null and cleans itself up safely.
			if slot.occupying_agent_weakref:
				var active_agent = slot.occupying_agent_weakref.get_ref()
				
				if active_agent == null:
					_clear_slot(slot)
					_update_target_collision_state(target)
				elif current_real_time > slot.lease_expiry_time:
					if active_agent.has_method("on_reservation_timeout"):
						active_agent.on_reservation_timeout()
					_clear_slot(slot)
					_update_target_collision_state(target)

```

#### 2. The Fixed GOAP Action

We must explicitly hand off the reference to the agent so the heartbeat ping can function.

```gdscript
# chop_wood_action.gd
# ... (inside perform block) ...

	if _target_node == null:
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

```