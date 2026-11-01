## smoke_loop_closure.gd — Headless full-loop smoke test (Wayfinder ticket #54)
## Walks the complete Phase-1 management loop programmatically:
##   boot -> establish camp -> order tent (blueprint) -> post forager jobs ->
##   run >= 3 daily ticks -> assert construction completed AND forager
##   production (Berries/Mushrooms) grew the stockpile.
## Complements smoke_slice.gd (#57, woodcutter-only data layer).
##
## Run:  godot --path src/feudal-age --headless --script res://tests/smoke_loop_closure.gd
## Exit: 0 = PASS, 1 = FAIL
extends SceneTree

const ZONE_ID: int = 1
const TICKS_TO_RUN: int = 4
const TENT_PATH: String = "res://data/blueprints/tent.tres"
const FORAGER_PATH: String = "res://data/blueprints/forager_post.tres"

var _frames_waited: int = 0
var _ticks_run: int = 0
var _stage: String = "boot"
var _gc: Node = null
var _timber_before_build: int = 0
var _berries_start: int = 0
var _mushrooms_start: int = 0
var _tent_started: bool = false
var _forager_posted: bool = false

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
			_frames_waited += 1
			if _frames_waited >= 5:
				_run_loop_setup()
		"verify":
			_verify_and_quit()
			return true
	return false

func _run_loop_setup() -> void:
	var service_locator: Node = root.get_node_or_null("ServiceLocator")
	var api: Node = service_locator.get_management_service() if service_locator else null
	if api == null:
		_fail("ManagementAPI not registered in ServiceLocator after boot")
		return
	var context: Resource = _gc.game_context
	if context == null or not context.world_nodes.has(ZONE_ID):
		_fail("Zone %d missing from world_nodes" % ZONE_ID)
		return
	var zone: Resource = context.world_nodes[ZONE_ID]

	# Wait for ManagementPopulantComponent registration (same as smoke_slice)
	if api._registered_populants.is_empty():
		if _frames_waited > 300:
			_fail("No ManagementPopulantComponent registered with ManagementAPI")
		return

	# STEP 1: Establish camp (wilderness -> CAMP)
	api.establish_camp(ZONE_ID)
	if zone.current_tier != ZoneNode.SettlementTier.CAMP:
		_fail("establish_camp did not raise tier to CAMP")
		return

	# STEP 2: Order a tent via the blueprint path (economy gate: Timber >= 25)
	if not ResourceLoader.exists(TENT_PATH):
		_fail("tent blueprint missing at %s" % TENT_PATH)
		return
	var tent: BuildingData = load(TENT_PATH)
	_timber_before_build = zone.stockpile.get("Timber", 0)
	var ordered: bool = api.order_building(ZONE_ID, tent)
	if not ordered:
		_fail("order_building(tent) refused — Timber=%d < cost %s" % [_timber_before_build, str(tent.build_cost)])
		return
	if zone.buildings.is_empty():
		_fail("zone.buildings empty after successful order")
		return
	_tent_started = true

	# STEP 3: Post forager jobs via the new manual-posting API (adds 2 slots)
	var posted: bool = api.post_manual_job(ZONE_ID, "forager", 2)
	if not posted:
		_fail("post_manual_job(forager) refused at CAMP tier")
		return
	_forager_posted = true

	# STEP 4: Ensure a forager worker exists and is assigned (recruit + assign)
	var forager_id: int = -1
	for char_id in api._registered_populants:
		var comp: Node = api._registered_populants[char_id]
		if comp.qualification_profile == "forager":
			forager_id = char_id
			break
	if forager_id != -1:
		api.recruit_populant_to_faction(forager_id, "player")
		if not api.assign_populant_to_node(forager_id, ZONE_ID):
			_fail("assign_populant_to_node(forager %d) returned false" % forager_id)
			return
	else:
		print("SMOKE: WARNING — no forager populant registered; forager production will rely on manual slot fallback")

	_berries_start = zone.stockpile.get("Berries", 0)
	_mushrooms_start = zone.stockpile.get("Mushrooms", 0)
	print("SMOKE: camp=%s tent ordered (Timber %d -> %d), forager postings added, workers=%d, postings=%s" % [
		zone.current_tier, _timber_before_build, zone.stockpile.get("Timber", 0),
		zone.local_workers.size(), str(zone.manual_job_postings)])

	# Stop realtime timer; tick deterministically
	for child in _gc.get_children():
		if child is Timer:
			child.stop()
	for i in range(TICKS_TO_RUN):
		_gc._on_simulation_tick_elapsed()
		_ticks_run += 1
	_stage = "verify"

func _verify_and_quit() -> void:
	var context: Resource = _gc.game_context
	var zone: Resource = context.world_nodes[ZONE_ID]
	var service_locator: Node = root.get_node_or_null("ServiceLocator")
	var api: Node = service_locator.get_management_service() if service_locator else null
	var tent: Resource = zone.buildings[0]
	var berries_now: int = zone.stockpile.get("Berries", 0)
	var mushrooms_now: int = zone.stockpile.get("Mushrooms", 0)

	print("SMOKE: after %d ticks — tent progress=%.1f/%d completed=%s, stockpile=%s" % [
		_ticks_run, tent.construction_progress, tent.blueprint.total_work_required,
		str(tent.is_completed), str(zone.stockpile)])

	if not tent.is_completed:
		_fail("tent construction did not complete after %d ticks (progress %.1f / %d, workers=%d)" % [
			_ticks_run, tent.construction_progress, tent.blueprint.total_work_required, zone.local_workers.size()])
		return
	var berries_delta: int = berries_now - _berries_start
	var mushrooms_delta: int = mushrooms_now - _mushrooms_start
	if berries_delta <= 0 and mushrooms_delta <= 0:
		_fail("forager production did not grow stockpile (Berries +%d, Mushrooms +%d over %d ticks)" % [
			berries_delta, mushrooms_delta, _ticks_run])
		return

	print("SMOKE: forager production verified — Berries +%d, Mushrooms +%d" % [berries_delta, mushrooms_delta])
	# TIMBER-GROWTH acceptance (#47/#68): with the tent complete there are no
	# open builder slots, so a posted woodcutter job must pull the woodcutter
	# worker into production — Timber must strictly increase over N ticks.
	var woodcutter_ok: bool = api.post_manual_job(ZONE_ID, "woodcutter", 1)
	if not woodcutter_ok:
		_fail("post_manual_job(woodcutter) refused")
		return
	var timber_before: int = zone.stockpile.get("Timber", 0)
	for i in range(TICKS_TO_RUN):
		_gc._on_simulation_tick_elapsed()
		_ticks_run += 1
	var timber_after: int = zone.stockpile.get("Timber", 0)
	if timber_after <= timber_before:
		_fail("Timber did not strictly increase over %d woodcutter ticks (before=%d, after=%d)" % [
			TICKS_TO_RUN, timber_before, timber_after])
		return
	print("SMOKE: timber growth verified — Timber %d -> %d over %d ticks" % [timber_before, timber_after, TICKS_TO_RUN])
	# ALL-3-BLUEPRINTS acceptance (#68): order the remaining two blueprints.
	zone.stockpile["Timber"] = zone.stockpile.get("Timber", 0) + 120  # smoke grant
	for bp_path in ["res://data/blueprints/forager_post.tres", "res://data/blueprints/charcoal_stack.tres"]:
		var bp: BuildingData = load(bp_path)
		if not api.order_building(ZONE_ID, bp):
			_fail("order_building(%s) refused" % bp_path)
			return
	if zone.buildings.size() < 3:
		_fail("expected >=3 buildings after ordering all blueprints, got %d" % zone.buildings.size())
		return
	print("SMOKE: all 3 blueprints orderable — forager_post + charcoal_stack accepted (Timber %d left)" % zone.stockpile.get("Timber", 0))
	print("SMOKE: PASS")
	quit(0)

func _fail(reason: String) -> void:
	printerr("SMOKE: FAIL — " + reason)
	quit(1)