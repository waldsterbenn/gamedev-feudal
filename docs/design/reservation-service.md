# Part 12: Game Design Document (GDD) — Spatial Reservation System

## 1. Architectural Philosophy & Intent

### 1.1 The "Tragedy of the Commons" Problem

In agent-based management simulations, decentralized planning algorithms (such as GOAP) can suffer from the "single target pile-up" issue. If five idle gatherers simultaneously check the state of the world, they may all identify the same fallen log as their cheapest foraging target. Without coordination, all five characters will march to the same coordinate. Only the first to arrive harvests the resource, while the remaining four waste labor time traveling.

### 1.2 The Smart Object Solution

To prevent this, *Wilderness Fief* implements a **Spatial Reservation System** based on industry-standard "Smart Object" design patterns. The reservation system acts as a centralized, lightweight gatekeeper (a leasing broker) registered globally under our service locator. Before an NPC's GOAP action transitions from *planning* to *execution*, it must negotiate a lease on its physical target.

If the lease is granted, the target object modifies its physical collision properties to become invisible to other agents' utility scans, preventing redundant travel loops and optimizing multi-agent coordination.

---

## 2. Advanced Spatial Reservation Best Practices

To achieve an industrial-grade simulation that scales to hundreds of agents without bottlenecking the CPU or trapping actors in logic deadlocks, the system integrates five foundational smart-object design paradigms.

### 2.1 The Two-Phase Reservation Pattern ("Claim" vs. "Occupy")

Rather than treating a reservation as a simple binary lock, the lease lifecycle is explicitly split into two functional phases: **Claimed** and **Occupy**.

* **Phase 1: Claimed (The Transit Phase):** The moment an agent selects a target, the resource is marked as "Claimed." It remains visible in the world but is immediately stripped from the pool of available choices for all other agents' planning engines. The agent is still physically traveling toward the target coordinate.
* **Phase 2: Occupied (The Interaction Phase):** When the agent's physics body enters the interaction zone, the status transitions to "Occupied." Only at this stage does the object trigger its internal logic updates (e.g., ticking down resource durability or modifying settlement inventory data).

> 💡 **Architectural Intent:** If an agent is struck by a projectile, drafted by the player, or intercepted by a starvation vital crisis during Phase 1, the reservation service quietly revokes the *Claim* with zero systemic side effects. The object never enters a half-corrupted state because mechanical work logic only triggers during Phase 2.

### 2.2 Multi-Slot Capacity (The Shared Interaction Node)

A single object in the 3D world is not strictly limited to a single worker. Structures like a community campfire, a large construction site, or an expansive warehouse pile support concurrent labor from multiple agents.

To support this, interactive entities do not lock their parent node; instead, they expose an array of discrete **Reservation Slots**.

* Each slot acts as an individual sub-lease with its own relative transform offset (e.g., Seat A at $x = -1.0$, Seat B at $x = 1.0$).
* Agents reserve individual slots rather than the root entity.
* The parent object only alters its global physics mask to flag itself as completely unavailable when *all* internal reservation slots have been successfully leased.

### 2.3 Lease Timeouts (Time-to-Live Pruning)

In real-time 3D environments, pathfinding meshes can break, steering systems can conflict, or an actor can get wedged behind world geometry. If an agent holds an absolute lock on a tree but gets physically stuck behind a rock, that resource is permanently lost to the colony's economic cycle.

To eliminate these "ghost locks," all claims are issued with a strict **Time-to-Live (TTL)** expiration value:

* When a claim is granted, it is stamped with a expiration timestamp ($\text{Lease Expiry} = \text{Current Time} + \text{TTL Duration}$).
* While traveling, the agent must periodically submit a "heartbeat" ping to renew its lease.
* If the agent is blocked or fails to submit a heartbeat before the TTL threshold, the reservation service cancels the lease, restores the object to the public search pool, and commands the stuck agent to clear its current corrupted plan.

### 2.4 Priority-Based Eviction

Settlement simulation tasks are fundamentally hierarchical. A peasant resting on a medical cot to recover from a minor muscle strain should not block an unassigned slot if a high-value knight returns from an active raid bleeding out.

The reservation system enforces a **Priority Level Matrix**:

$$\text{Request Access Granted} \iff \text{Slot Available} \lor (\text{Request Priority} > \text{Active Holder Priority})$$

When a high-priority action requests a slot currently occupied by a low-priority task, the reservation service initiates an **Eviction Sequence**:

1. The low-priority agent's lease is immediately revoked.
2. The service sends an explicit `evicted` callback to the low-priority agent, forcing its animation state machine to halt execution and clean up its parameters.
3. The slot is seamlessly re-assigned to the high-priority agent.
4. The evicted agent returns to an idle state and evaluates alternative tasks during its next tactical tick window.

### 2.5 Event-Driven Invalidation Callbacks

The world state is highly volatile. A forest fire can destroy a tree cluster, a structural component can be disassembled, or a player can use a bulldozer tool to delete a construction blueprint while multiple NPCs are actively walking toward those coordinates.

To avoid null-pointer exceptions or pathfinding crashes, the relationship between target and agent is bound via an **Event Invalidation Pipeline**:

* When a world entity is compromised or deleted, it triggers an internal destruction broadcast.
* The reservation service intercepts this call, cross-references its memory table, identifies every agent currently holding an active claim on that entity's slot indices, and fires a clean cancellation signal directly to them.
* The target actors smoothly abort their current physical traversal loops, clear their local target parameters, and safely drop back into a neutral state without generating logic faults.

---

## 3. Spatial Reservation States

| Reservation State | Physics Layer Assignment | Planning Pool Status | Active Behavioral Loop |
| --- | --- | --- | --- |
| **Available** | `Layer 5: Interactive_Available` | Visible to all search algorithms. | Awaiting assignment hooks. |
| **Claimed** | `Layer 6: Interactive_Reserved` (If slots full) | Hidden from new utility calculations. | Agent is navigating towards the local slot offset. |
| **Occupied** | `Layer 6: Interactive_Reserved` | Hidden from new utility calculations. | Agent has arrived; playing cosmetic work animation loops. |

---

---

# Part 13: Technical Design Document (TDD) — Spatial Reservation System

## 1. Local Scene Structure

The `ReservationService` is deployed as an autoloaded global coordinator. Interactive objects in the 3D space interact with this service using explicit node references and custom metadata parameters.

```
[GameCoordinator Node]
 └── ReservationService (Autoload / Node) <-- [Manages TTL, Slots, Evictions & Layer Swaps]

```

---

## 2. Component & Core Script Specifications

### 2.1 The Architectural Sub-Resource Data Structures

To handle prioritization, slot allocation, and time tracking cleanly, we encapsulate lease information within lean, type-safe resource objects.

```gdscript
# reservation_slot.gd
extends Resource
class_name ReservationSlot

@export var local_offset: Vector3 = Vector3.ZERO
var occupying_agent_weakref: WeakRef = null
var current_priority: int = 0
var lease_expiry_time: float = 0.0

```

### 2.2 The Refactored Global Reservation Service

This centralized system manages slot maps, monitors lease expirations on the tactical tick, and handles priority-based evictions.

```gdscript
# reservation_service.gd
extends Node

const LAYER_AVAILABLE: int = 5
const LAYER_RESERVED: int = 6
# FIX 1: Use real machine time (TTL in seconds of real wall-clock time, not in-game time)
const LEASE_TTL_REAL_SECONDS: float = 15.0

func _ready() -> void:
	# Bind lease expiration sweeps directly to our centralized tactical clock ticker
	TimeEngine.game_tick_passed.connect(_on_tactical_clock_tick)

## High-Level Interface: Dynamically initializes a node's reservation slot profiles
func initialize_reservation_slots(target: Node3D, slot_count: int, offsets: Array[Vector3] = []) -> void:
	var slots: Array[ReservationSlot] = []
	for i in range(slot_count):
		var slot = ReservationSlot.new()
		if i < offsets.size():
			slot.local_offset = offsets[i]
		slots.append(slot)
	target.set_meta("reservation_slots", slots)
	
	# Default setup: Place newly spawned interactive items on the public layer
	target.set_collision_layer_value(LAYER_AVAILABLE, true)
	target.set_collision_layer_value(LAYER_RESERVED, false)

## Requests a lease on a target object. Integrates priority-based evictions.
func request_slot_reservation(agent: Node3D, target: Node3D, priority: int) -> bool:
	if not is_instance_valid(agent) or not is_instance_valid(target) or not target.has_meta("reservation_slots"):
		return false
		
	var slots: Array = target.get_meta("reservation_slots")
	var best_eviction_target: ReservationSlot = null
	var lowest_active_priority: int = INF
	
	# Step A: Evaluate available slots or locate a low-priority target to evict
	for slot in slots:
		var holder = slot.occupying_agent_weakref.get_ref() if slot.occupying_agent_weakref else null
		
		# Found an open slot: Book it immediately
		if holder == null:
			_assign_slot_lease(agent, slot, target, priority)
			return true
			
		# Track the lowest priority actor currently working here for eviction assessment
		if slot.current_priority < lowest_active_priority:
			lowest_active_priority = slot.current_priority
			best_eviction_target = slot

	# Step B: Execute priority-based eviction if no slots are free
	if priority > lowest_active_priority and best_eviction_target != null:
		var evicted_agent = best_eviction_target.occupying_agent_weakref.get_ref()
		
		# FIX 3: Explicitly clear the evicted agent's slot BEFORE assigning it to the new agent
		# to prevent ghost data leaking into the service.
		_clear_slot(best_eviction_target)
		
		if evicted_agent and evicted_agent.has_method("on_reservation_evicted"):
			evicted_agent.on_reservation_evicted()
			
		_assign_slot_lease(agent, best_eviction_target, target, priority)
		return true
		
	return false

## Extends lease TTL during agent transit (Heartbeat Pattern)
func refresh_lease_heartbeat(agent: Node3D, target: Node3D) -> void:
	if not is_instance_valid(target) or not target.has_meta("reservation_slots"):
		return
	var slots: Array = target.get_meta("reservation_slots")
	for slot in slots:
		if slot.occupying_agent_weakref and slot.occupying_agent_weakref.get_ref() == agent:
			# FIX 1: Use absolute machine time, not in-game simulated time
			slot.lease_expiry_time = (Time.get_ticks_msec() / 1000.0) + LEASE_TTL_REAL_SECONDS
			return

## Explicitly releases an agent's held slot lease
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
		
	# If slots open back up, return the object to the public search layer
	if all_slots_free:
		target.set_collision_layer_value(LAYER_AVAILABLE, true)
		target.set_collision_layer_value(LAYER_RESERVED, false)

## Internal Helper: Binds the data properties cleanly to the slot resource
func _assign_slot_lease(agent: Node3D, slot: ReservationSlot, target: Node3D, priority: int) -> void:
	slot.occupying_agent_weakref = weakref(agent)
	slot.current_priority = priority
	# FIX 1: Use real machine time for lease expiry timestamp
	slot.lease_expiry_time = (Time.get_ticks_msec() / 1000.0) + LEASE_TTL_REAL_SECONDS
	
	# FIX 2: Removed buggy Godot 4 Callable.bind() signal connections entirely.
	# In Godot 4, .bind() generates a new Callable object each time, so is_connected()
	# always returns false and disconnect() always fails — causing duplicate connections
	# and a silent memory leak. Passive WeakRef GC in _on_tactical_clock_tick handles cleanup.
	
	# Evaluate if the node is now full
	_update_target_collision_state(target)

# FIX 2: Removed agent parameter — no signal disconnection needed anymore.
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

## Real-time optimization pass running off the tactical clock thread
func _on_tactical_clock_tick() -> void:
	# FIX 1: Use real machine time, not in-game simulated time
	var current_real_time = Time.get_ticks_msec() / 1000.0
	var active_targets = get_tree().get_nodes_in_group("interactive_objects")
	
	for target in active_targets:
		if not target.has_meta("reservation_slots"): continue
		var slots: Array = target.get_meta("reservation_slots")
		
		for slot in slots:
			if slot.occupying_agent_weakref:
				var active_agent = slot.occupying_agent_weakref.get_ref()
				
				# FIX 2: Passive garbage collection — if the agent was deleted,
				# .get_ref() returns null and the slot cleans itself up safely.
				if active_agent == null:
					_clear_slot(slot)
					_update_target_collision_state(target)
				# Break the lock if the agent exceeds their travel time without a heartbeat ping
				elif current_real_time > slot.lease_expiry_time:
					if active_agent.has_method("on_reservation_timeout"):
						active_agent.on_reservation_timeout()
					_clear_slot(slot)
					_update_target_collision_state(target)

```

---

### 2.3 Physical Object Setup Interface

Any node placed in the 3D scene that can be worked or harvested must run this setup routine during its initialization pass.

```gdscript
# interactive_tree_node.gd
extends StaticBody3D

@export var max_worker_capacity: int = 2

func _ready() -> void:
	add_to_group("interactive_objects")
	
	# Define separate worker slot offsets so agents stand at different spots around the tree
	var positional_offsets: Array[Vector3] = [
		Vector3(-1.2, 0.0, 0.0), # Slot 1: Left
		Vector3(1.2, 0.0, 0.0)   # Slot 2: Right
	]
	
	# Register slots automatically with the global service
	ServiceLocator.get_reservation_service().initialize_reservation_slots(self, max_worker_capacity, positional_offsets)

## Event-Driven Invalidation: Notify agents if the player deletes this tree mid-game
func _exit_tree() -> void:
	if has_meta("reservation_slots"):
		var slots: Array = get_meta("reservation_slots")
		for slot in slots:
			if slot.occupying_agent_weakref:
				var agent = slot.occupying_agent_weakref.get_ref()
				if agent and agent.has_method("on_target_invalidated"):
					agent.on_target_invalidated(self)

```

---

### 2.4 Refactored GOAP Agent Integration

This character code handles lease extensions (heartbeats), priority registration, eviction overrides, and timeout safety signals.

```gdscript
# spatial_npc_agent.gd
extends CharacterBody3D

@onready var goap_agent: Node = $GoapAgent
var active_target_node: Node3D = null
var heartbeat_accumulator: float = 0.0

func _process(delta: float) -> void:
	if is_instance_valid(active_target_node):
		heartbeat_accumulator += delta
		# Send a heartbeat every 5 seconds to extend our lease while traveling
		if heartbeat_accumulator >= 5.0:
			heartbeat_accumulator = 0.0
			ServiceLocator.get_reservation_service().refresh_lease_heartbeat(self, active_target_node)

## Priority-Based Eviction Callback
func on_reservation_evicted() -> void:
	_force_abort_current_task("EVICTED_BY_HIGH_PRIORITY_ACTOR")

## Lease Timeout Callback
func on_reservation_timeout() -> void:
	_force_abort_current_task("LEASE_TIMEOUT_EXPIRED")

## Event-Driven Invalidation Callback
func on_target_invalidated(destroyed_node: Node3D) -> void:
	if active_target_node == destroyed_node:
		_force_abort_current_task("TARGET_DESTROYED_BY_EXTERNAL_EVENT")

func _force_abort_current_task(reason: String) -> void:
	active_target_node = null
	heartbeat_accumulator = 0.0
	
	# Force the GOAP solver to cancel execution loops immediately and replan
	goap_agent.interrupt_active_action_sequence()

```