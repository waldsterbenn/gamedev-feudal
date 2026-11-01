extends SceneTree
## Smoke #85: building-driven capacity, storage caps, foreman bonus,
## auto-queued tent, housing cap, and consumption math.
## Stage-machine over _process (await does not resume in --script mode).

var _stage: int = 0
var _api: Node = null
var _zone: Resource = null
var _frames: int = 0
var _gc: Node = null

func _process(_delta: float) -> bool:
	_frames += 1
	match _stage:
		0:
			if _gc == null:
				var gc_scene: PackedScene = load("res://scenes/gamecoordinator/GameCoordinator.tscn")
				_gc = gc_scene.instantiate()
				root.add_child(_gc)
				return false
			# Wait for _ready chains (WorldInitializer, ServiceLocator)
			if _frames < 8:
				return false
			var sl: Node = root.get_node_or_null("ServiceLocator")
			_api = sl.get_management_service() if sl else null
			if _api == null:
				_fail("ManagementAPI not registered")
				return true
			var context: Resource = _gc.game_context
			_zone = context.world_nodes[1]
			_stage = 1
		1:
			# Camp establishment: tent auto-queued, NOT completed
			_api.establish_camp(1)
			var b: Resource = _zone.buildings[0]
			if b.blueprint.building_id != "tent" or b.is_completed:
				_fail("establish_camp did not auto-queue a tent")
				return true
			print("SMOKE: tent auto-queued on establish_camp")
			_stage = 2
		2:
			# Consumption: 2 residents, 1 food each/day, berries first.
			# No jobs posted, no production -> berries 10 -> 8, mushrooms 10.
			_tick()
			if _zone.stockpile.get("Berries", -1) != 8 or _zone.stockpile.get("Mushrooms", -1) != 10:
				_fail("consumption math wrong: %s (expected Berries 8, Mushrooms 10)" % str(_zone.stockpile))
				return true
			print("SMOKE: consumption verified — 2 residents ate 2 berries in 1 tick")
			_stage = 3
		3:
			# Storage caps: complete a Forager Hut programmatically, fill
			# berries near cap, post 2 foragers, tick — halts AT cap exactly.
			var hut := _force_complete("forager_hut")
			if hut == null:
				_fail("forager_hut blueprint missing")
				return true
			if not _api.adjust_job_target(1, "forager", 2):
				_fail("forager target adjust refused")
				return true
			_zone.stockpile["Berries"] = 47
			_tick()
			# yield = roundi(2*5*0.5) = 5 -> capped at 50 exactly; 2 residents ate 2
			if _zone.stockpile.get("Berries", -1) != 50:
				_fail("berry cap/halt wrong: %s (expected 50)" % str(_zone.stockpile.get("Berries")))
				return true
			print("SMOKE: berries capped at 50 — production halted at cap")
			_stage = 4
		4:
			# At-cap tick: consumption frees room, capped production refills
			# EXACTLY to cap (never overflows) — net stays 50.
			var before: int = _zone.stockpile.get("Berries", 0)
			_tick()
			if _zone.stockpile.get("Berries", -1) != before:
				_fail("at cap: expected net 0 (2 eaten + 2 capped yield), got %d" % _zone.stockpile.get("Berries"))
				return true
			print("SMOKE: at cap — consumption + capped yield cancel out, never exceeds cap")
			_stage = 5
		5:
			# Foreman bonus: complete Foreman's Tent, house a 3rd resident,
			# post foreman 1, tick — mushrooms yield 3 instead of 2.
			var ft := _force_complete("foremans_tent")
			var tent := _force_complete("tent")
			if ft == null or tent == null:
				_fail("foremans_tent/tent blueprint missing")
				return true
			# Recruit zone-2's forager into zone 1 (housing now 4, residents 2)
			var external_id: int = -1
			for char_id in _api._registered_populants:
				if _api._registered_populants[char_id].assigned_node_id != 1:
					external_id = char_id
					break
			_api.recruit_populant_to_faction(external_id, "player")
			if not _api.assign_populant_to_node(external_id, 1):
				_fail("3rd resident refused while housing available (capacity 4)")
				return true
			if not _api.adjust_job_target(1, "foreman", 1):
				_fail("foreman target adjust refused")
				return true
			_tick()
			# mouths=3: berries 50 -> eat 3 -> 47 -> capped yield min(6, 3) -> 50.
			# Mushrooms (uncapped): yield roundi(2*3*0.4*1.25)=3 vs 2 without
			# foreman; accumulated 12 -> 14 over stages 3-4 -> 17 now.
			if _zone.stockpile.get("Berries", -1) != 50:
				_fail("berries exceeded cap with foreman: %s" % str(_zone.stockpile))
				return true
			var mushrooms: int = _zone.stockpile.get("Mushrooms", -1)
			if mushrooms != 17:
				_fail("foreman bonus wrong: mushrooms %d (expected 17 = 14 + 3)" % mushrooms)
				return true
			print("SMOKE: foreman bonus verified — mushrooms 14 -> 17 (+3 with +25% mult vs +2 base), berries stay capped at 50")
			_stage = 6
		6:
			# Housing cap: capacity 4 (tent), residents 3 -> 4 ok, 5th refused
			var pulled: int = 0
			var refused: bool = false
			for char_id in _api._registered_populants:
				if pulled < 2 and _api._registered_populants[char_id].assigned_node_id != 1:
					_api.recruit_populant_to_faction(char_id, "player")
					if _api.assign_populant_to_node(char_id, 1):
						pulled += 1
					else:
						refused = true
			if pulled != 1 or not refused:
				_fail("housing cap wrong — pulled %d, refused %s (expected pull 1 then refuse)" % [pulled, str(refused)])
				return true
			if _zone.local_workers.size() != 4:
				_fail("residents %d != 4 after cap enforcement" % _zone.local_workers.size())
				return true
			print("SMOKE: housing cap verified — 4/4 residents, 5th refused")
			_stage = 7
		7:
			# Famine latch (#92): zero production first (forager posting -> 0)
			# so the unfed tick can't be refilled in the same tick, then drain
			# food -> residents unfed -> latch closes at END of tick.
			_api.adjust_job_target(1, "forager", -2)
			_zone.stockpile["Berries"] = 0
			_zone.stockpile["Mushrooms"] = 0
			_tick()
			if not _zone.famine_latched:
				_fail("famine: latch did not close after residents went unfed")
				return true
			print("SMOKE: famine latched — residents unfed, latch closed at tick end")
			_stage = 8
		8:
			# Latched tick: everyone off the land, trickle banks food (6 < 8
			# needed) -> still latched; org drained to 0.
			_tick()
			if _zone._get_assigned_count("off_the_land") != 4:
				_fail("famine: expected 4 off the land, got %d" % _zone._get_assigned_count("off_the_land"))
				return true
			if _zone._get_assigned_count("forager") != 0:
				_fail("famine: foragers still manned")
				return true
			var food: int = _zone.stockpile.get("Berries", 0) + _zone.stockpile.get("Mushrooms", 0)
			if food != 6:
				_fail("famine: trickle banked %d food, expected 6 (4 berries + 2 mushrooms)" % food)
				return true
			if _zone.famine_latched == false:
				_fail("famine: unlatched before 2x buffer (food=%d needed=8)" % food)
				return true
			print("SMOKE: famine tick — 4 off the land, trickle banked 6/8, org drained %d" % int(_zone.camp_organization))
			_stage = 9
		9:
			# Work through starvation (#92): order + cover an incomplete
			# building, toggle ON — 1 builder crawls at half speed, 3 rest.
			var lumber_bp: Resource = load("res://data/blueprints/lumber_camp.tres")
			_api.order_building(1, lumber_bp)
			_zone.allocated_construction_resources["Timber"] = 40  # cover its cost
			_api.toggle_work_through_famine(1, true)
			var progress_before: float = 0.0
			for building in _zone.buildings:
				if building.blueprint.building_id == "lumber_camp":
					progress_before = building.construction_progress
			_tick()
			if _zone._get_assigned_count("builder") != 1:
				_fail("work-through: expected 1 builder, got %d" % _zone._get_assigned_count("builder"))
				return true
			if _zone._get_assigned_count("off_the_land") != 3:
				_fail("work-through: expected 3 off the land, got %d" % _zone._get_assigned_count("off_the_land"))
				return true
			for building in _zone.buildings:
				if building.blueprint.building_id == "lumber_camp":
					if building.construction_progress - progress_before != 5.0:
						_fail("work-through: progress +%f, expected +5.0 (half speed)" % (building.construction_progress - progress_before))
						return true
			print("SMOKE: work-through verified — 1 builder at half speed (+5 labor), 3 off the land")
			_stage = 10
		10:
			# Toggle OFF + escape: crawl resumes; stock climbs to the 2x
			# buffer (8) and the latch OPENS at end of tick.
			_api.toggle_work_through_famine(1, false)
			_tick()
			if _zone.famine_latched:
				_fail("famine: still latched after banking the 2x buffer")
				return true
			print("SMOKE: famine escaped — food hit the 2x buffer, workplaces re-manned")
			_stage = 11
		11:
			# Recovery: re-post foragers, normal tick re-mans workplaces from
			# postings; foreman regrows Organization.
			_api.adjust_job_target(1, "forager", 2)
			_tick()
			if _zone._get_assigned_count("forager") != 2:
				_fail("famine recovery failed — foragers assigned %d != 2" % _zone._get_assigned_count("forager"))
				return true
			if _zone.camp_organization < 10.0:
				_fail("organization did not regrow with foreman (org=%f)" % _zone.camp_organization)
				return true
			print("SMOKE: recovery verified — foragers re-manned, Organization regrowing (%d/100)" % int(_zone.camp_organization))
			print("SMOKE: PASS")
			quit(0)
			return true
	return false

func _tick() -> void:
	_gc._on_simulation_tick_elapsed()

## Completes (ordering first if needed) the building of the given id.
func _force_complete(building_id: String) -> Resource:
	var bp: Resource = load("res://data/blueprints/%s.tres" % building_id)
	if bp == null:
		return null
	for building in _zone.buildings:
		if building.blueprint.building_id == building_id:
			building.is_completed = true
			building.construction_progress = building.blueprint.total_work_required
			return building
	_api.order_building(1, bp)
	for building in _zone.buildings:
		if building.blueprint.building_id == building_id:
			building.is_completed = true
			building.construction_progress = building.blueprint.total_work_required
			return building
	return null

func _fail(reason: String) -> void:
	print("SMOKE: FAIL — " + reason)
	quit(1)
