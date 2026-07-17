# Part 8: Game Design Document (GDD) — Tick & Time Engine

## 1. Design Vision & Time-Scale Mechanics

The time system in *Wilderness Fief* coordinates the background economic simulation with the continuous 3D world. It balances fast, fluid animations with slow, low-overhead resource math.

### 1.1 Time Conversions

The progression of time uses a standardized conversion multiplier ($\text{Time Scale} = 60.0$). Under this configuration, in-game clock metrics translate directly to real-world performance as follows:

* **1 In-Game Hour:** 1 Real-World Minute ($60\text{ s}$).
* **1 In-Game Day (24 Hours):** 24 Real-World Minutes ($1440\text{ s}$).
* **1 In-Game Year (4 Seasons, 12 Months, 360 Days):** 144 Real-World Hours.

This compression ensures that physical tasks (like walking between nodes) feel naturally paced compared to long-term resource gathering and crop growth.

---

## 2. Multi-Tiered Tick Rates

To prevent CPU bottlenecks, execution is split into three separate tick rates based on what needs to be calculated:

| Tick Tier | Frequency | Target Subsystems | Architectural Intent |
| --- | --- | --- | --- |
| **Visual Frame Tick** | $\sim 60\text{ Hz}$ (`_process`) | Camera, animations, celestial sky rotation, UI dials. | High-fidelity feedback. |
| **Tactical Game Tick** | $1.0\text{ Hz}$ ($1.0\text{ s}$ intervals) | GOAP blackboard updates, sensory range checks, path updates. | Regular background logic. |
| **Logistical Sim Tick** | $1.0\text{ in-game hour}$ ($60.0\text{ s}$ intervals) | Food rot, tax collection, labor ledger allocation, seasonal shifts. | Headless economic backend. |

---

## 3. Celestial Day/Night Synchronization

To maintain absolute temporal coherence, the visual placement of the sun and moon is directly bound to the global, authoritative game time.

```
          [ Global Game Time (Seconds Passed) ]
                           │
                           ▼
          [ Global Time Engine (TimeScale) ]
                           │
                  (Broadcasts Angles)
                           │
         ┌─────────────────┴─────────────────┐
         ▼                                   ▼
 [ DirectionalLight3D ]            [ Sky/Atmosphere Shader ]
 (Sun Pitch/Yaw Rotation)          (Sky color, cloud density)

```

The pitch of the main sun light is calculated dynamically:

$$\theta_{\text{sun}} = \left( \frac{t_{\text{current}} \bmod 86400}{86400} \cdot 360^\circ \right) - 90^\circ$$

Where $t_{\text{current}}$ represents the current accumulated seconds of the in-game day. An offset of $-90^\circ$ aligns the astronomical noon ($12:00$) with the sun's highest point directly overhead.

---

---

# Part 9: Technical Design Document (TDD) — Tick & Time Engine

## 1. Local Scene Structure

The `TimeEngine` sits as a core autoloaded service, allowing any UI container, celestial controller, or AI agent to query time parameters instantly.

```
[GameCoordinator Node]
 └── TimeEngine (Autoload / Node)   <-- [Authorized Timekeeper & Signal Broadcaster]
      ├── TacticalTickTimer (Timer) <-- Ticks at 1.0s
      └── LogisticalTickTimer (Timer) <-- Ticks at 60.0s (In-game hour)

```

---

## 2. Component & Core Script Specifications

### 2.1 The Time Engine Autoload

This class manages the core time-state variables, increments the absolute continuous simulation clock, and triggers localized event dispatches.

```gdscript
# time_engine.gd
extends Node

# Signal dispatches for different system frequencies
signal game_tick_passed
signal logistical_tick_passed(current_hour: int, current_day: int)

const TIME_SCALE: float = 60.0 # 1 real second = 60 in-game seconds (1 minute)
const SECONDS_PER_IN_GAME_DAY: int = 86400

# Authoritative State Tracking
var absolute_elapsed_seconds: float = 28800.0 # Starts at 08:00 AM (28800 seconds)

@onready var tactical_timer: Timer = $TacticalTickTimer
@onready var logistical_timer: Timer = $LogisticalTickTimer

func _ready() -> void:
	_setup_timers()

func _process(delta: float) -> void:
	# Keep absolute continuous game clock up to date
	absolute_elapsed_seconds += delta * TIME_SCALE

func _setup_timers() -> void:
	# 1. Tactical Tick Setup (1.0 Hz Real-Time)
	tactical_timer.wait_time = 1.0
	tactical_timer.autostart = true
	tactical_timer.timeout.connect(_on_tactical_timeout)
	
	# 2. Logistical Sim Tick Setup (60.0s Real-Time = 1.0 hour in-game)
	logistical_timer.wait_time = 60.0
	logistical_timer.autostart = true
	logistical_timer.timeout.connect(_on_logistical_timeout)

func _on_tactical_timeout() -> void:
	game_tick_passed.emit()

func _on_logistical_timeout() -> void:
	var total_hours_passed = int(absolute_elapsed_seconds) / 3600
	var current_hour_of_day = total_hours_passed % 24
	var current_day = (int(absolute_elapsed_seconds) / SECONDS_PER_IN_GAME_DAY) + 1
	
	logistical_tick_passed.emit(current_hour_of_day, current_day)

# Accessor helpers for UI/AI queries
func get_time_string() -> String:
	var time_in_day = int(absolute_elapsed_seconds) % SECONDS_PER_IN_GAME_DAY
	var hours = time_in_day / 3600
	var minutes = (time_in_day % 3600) / 60
	return "%02d:%02d" % [hours, minutes]

```

### 2.2 Day/Night Celestial Synchronizer

This spatial script updates directional lighting transforms on the frame tick, calculating solar coordinates dynamically.

```gdscript
# celestial_synchronizer.gd
extends Node3D

@export var sun_light: DirectionalLight3D
@export var moon_light: DirectionalLight3D

# Base offset alignments
@export var orbital_inclination_degrees: float = 15.0

func _process(_delta: float) -> void:
	if not sun_light or not moon_light:
		return
		
	var seconds_today: float = fmod(TimeEngine.absolute_elapsed_seconds, TimeEngine.SECONDS_PER_IN_GAME_DAY)
	var daily_ratio: float = seconds_today / TimeEngine.SECONDS_PER_IN_GAME_DAY
	
	# Celestial Rotation Calculations
	var sun_pitch: float = (daily_ratio * 360.0) - 90.0
	var moon_pitch: float = sun_pitch + 180.0 # Moon stays directly opposite
	
	# Apply spatial transforms to sun
	sun_light.rotation_degrees = Vector3(sun_pitch, orbital_inclination_degrees, 0.0)
	moon_light.rotation_degrees = Vector3(moon_pitch, orbital_inclination_degrees, 0.0)
	
	# Energy adjustment: Fade out lights when they dip below the horizon line
	sun_light.visible = (sun_pitch > -175.0 and sun_pitch < -5.0)
	moon_light.visible = not sun_light.visible

```

### 2.3 Logistical Module Integration

An example of how backend simulation engines safely connect to the `logistical_tick_passed` signal to process economic data without impacting frames.

```gdscript
# food_decay_processor.gd
extends Node

func _ready() -> void:
	# Only execute during the slow logistical tick intervals
	TimeEngine.logistical_tick_passed.connect(_on_logistical_hour_passed)

func _on_logistical_hour_passed(current_hour: int, current_day: int) -> void:
	var api = ServiceLocator.get_management_service()
	if not api:
		return
		
	# Apply standard linear decay math to raw management inventory values
	# Costs zero frame compute budget!
	api.calculate_inventory_spoilage_step()

```

---

## 3. Temporal State Synchronization Rules

### 3.1 Time Scale Safety Guardrails

To prevent game-state fragmentation or frame physics collapse during high-speed transitions (such as "Fast Forward" options), the game engine restricts frame calculation scaling.

* **Physics Isolation:** Godot's internal physical calculation rate (`Engine.physics_ticks_per_second`) remains strictly locked at its baseline rate.
* **Safe Time Acceleration:** Scaling is achieved purely by multiplying the `TIME_SCALE` variable in the `TimeEngine` (e.g., setting `TIME_SCALE = 180.0` for $3\times$ speed). Because physics and visual frame transitions do not scale with the variable, physical character collision systems remain completely stable.

### 3.2 Future Scalability Rework Note: Threaded Offloading

> 📝 **Architectural Roadmap Optimization:** As the management database scales to handle thousands of items, crops, and dynamic simulation parameters across multiple rival fiefs, executing the full simulation sweep within `_on_logistical_timeout` directly on Godot's main main thread risks creating visible micro-stutters.
> A planned future optimization pass should replace the synchronous execution pipeline inside `time_engine.gd` with Godot 4's native **`WorkerThreadPool`** utility. Instead of direct signal dispatches executing on the main game thread, heavy processing routines (such as `calculate_inventory_spoilage_step()`) will be wrapped into asynchronous task callables via `WorkerThreadPool.add_task()`. This will securely isolate continuous background simulation updates from the visual rendering pipeline, maintaining an uninhibited $60\text{ Hz}$ frame presentation loop.