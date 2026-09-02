## smoke_slice.gd — Headless slice smoke test (Wayfinder ticket #57)
## Implements the two-stage gate's second stage defined by #55:
## boots GameCoordinator.tscn headless, drives the data layer
## (ManagementAPI.establish_camp + assign_populant_to_node for zone 1
## "Ironwood Hollow", whose spawn includes a woodcutter), runs >= 3 daily
## ticks, and asserts real FiefStateResource mutation (Timber > 0).
##
## Run:  godot --path src/feudal-age --headless --script res://tests/smoke_slice.gd
## Exit: 0 = PASS, 1 = FAIL
extends SceneTree

const ZONE_ID: int = 1
const ZONE_NAME: String = "Ironwood Hollow"
const TICKS_TO_RUN: int = 3

var _frames_waited: int = 0
var _ticks_seen: int = 0
var _stage: String = "boot"
var _failure: String = ""

func _init() -> void:
	# Defer scene loading to the first process frame: autoload globals
	# (ServiceLocator, EventBus) are not registered as script identifiers yet
	# during _init in --script mode, and loading the GC scene here would fail
	# to compile ManagementAPI/NPCCoordinator.
	pass

var _gc: Node = null

func _process(_delta: float) -> bool:
	match _stage:
		"boot":
			if _gc == null:
				var gc_scene: PackedScene = load("res://scenes/gamecoordinator/GameCoordinator.tscn")
				if gc_scene == null:
					_fail("GameCoordinator.tscn failed to load")
					return true
				_gc = gc_scene.instantiate()
				root.add_child(_gc)
				return false
			# Wait a few frames so _ready chains (WorldInitializer, NPC spawns,
			# ServiceLocator registration) have completed.
			_frames_waited += 1
			if _frames_waited >= 5:
				_run_data_layer_setup()
		"ticking":
			# GameCoordinator ticks on its own Timer (3 s/day by default);
			# count ticks via the GC's printed day counter by reading module
			# side effects instead: wait 3 full timer periods per tick.
			pass
		"verify":
			_verify_and_quit()
			return true
	return false

func _run_data_layer_setup() -> void:
	var service_locator: Node = root.get_node_or_null("ServiceLocator")
	var api: Node = service_locator.get_management_service() if service_locator else null
	if api == null:
		_fail("ManagementAPI not registered in ServiceLocator after boot")
		return
	var context: Resource = _gc.game_context
	if context == null or context.world_nodes.is_empty():
		_fail("FiefStateResource has no world_nodes after WorldInitializer boot")
		return
	if not context.world_nodes.has(ZONE_ID):
		_fail("Expected zone %d (%s) missing from world_nodes" % [ZONE_ID, ZONE_NAME])
		return

	# ManagementPopulantComponent._ready() registers NPCs with the API only
	# after the initial tree finishes readying. Wait until at least one
	# populant component is registered before driving assignments.
	if api._registered_populants.is_empty():
		if _frames_waited > 300:
			_fail("No ManagementPopulantComponent ever registered with ManagementAPI")
		return
	_frames_waited = 0

	# Establish the camp (wilderness -> CAMP tier; ticks are no-ops in WILDERNESS).
	api.establish_camp(ZONE_ID)

	# Ensure a woodcutter job slot exists (manual posting stands in for the
	# building blueprint the loop-closure ticket will introduce later).
	var zone: Resource = context.world_nodes[ZONE_ID]
	zone.manual_job_postings = {"woodcutter": 1}

	# Drive the data layer: recruit + assign a woodcutter populant to zone 1.
	# (The WorldInitializer boot-time assignment runs before component
	# registration, so the smoke re-issues it through the public API.)
	var woodcutter_id: int = -1
	for char_id in api._registered_populants:
		var comp: Node = api._registered_populants[char_id]
		if comp.qualification_profile == "woodcutter":
			woodcutter_id = char_id
			break
	if woodcutter_id == -1:
		var quals: Array = []
		for char_id in api._registered_populants:
			quals.append(str(api._registered_populants[char_id].qualification_profile))
		_fail("No woodcutter populant registered (%d populants, quals=%s)" % [api._registered_populants.size(), str(quals)])
		return
	api.recruit_populant_to_faction(woodcutter_id, "player")
	if not api.assign_populant_to_node(woodcutter_id, ZONE_ID):
		_fail("assign_populant_to_node(%d, %d) returned false" % [woodcutter_id, ZONE_ID])
		return

	print("SMOKE: camp established at zone %d, workers=%d, postings=%s" % [
		ZONE_ID, zone.local_workers.size(), str(zone.manual_job_postings)])

	# Stop the GC's realtime timer — we tick deterministically instead.
	for child in _gc.get_children():
		if child is Timer:
			child.stop()

	# Run >= 3 daily ticks.
	for i in range(TICKS_TO_RUN):
		_gc._on_simulation_tick_elapsed()
		_ticks_seen += 1

	_stage = "verify"

func _verify_and_quit() -> void:
	var context: Resource = _gc.game_context
	var zone: Resource = context.world_nodes[ZONE_ID]
	var timber: int = zone.stockpile.get("Timber", 0)
	var canopy: float = zone.canopy_density

	print("SMOKE: after %d ticks — Timber=%d, canopy_density=%.4f, stockpile=%s" % [
		_ticks_seen, timber, canopy, str(zone.stockpile)])

	if timber <= 0:
		_fail("Timber stockpile did not grow (Timber=%d after %d ticks)" % [timber, _ticks_seen])
		return

	if canopy >= 1.0:
		print("SMOKE: WARNING — canopy_density unchanged (%.4f); Pillar-4 observable not exercised" % canopy)

	print("SMOKE: PASS")
	quit(0)

func _fail(reason: String) -> void:
	_failure = reason
	printerr("SMOKE: FAIL — " + reason)
	quit(1)
