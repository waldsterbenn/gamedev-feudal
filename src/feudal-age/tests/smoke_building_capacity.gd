extends SceneTree
## Smoke #85: building-driven capacity, storage caps, foreman bonus,
## auto-queued tent, housing cap, and consumption math.
## Stage-machine over _process (await does not resume in --script mode).

var _stage: int = 0
var _api: Node = null
var _zone: Resource = null
var _grind: int = 0
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
			# Foreman bonus + TENT AUTO-FILL (#91 v4): completing the tent
			# fills housing to capacity — residents 2 -> 4 instantly.
			var ft := _force_complete("foremans_tent")
			var tent := _force_complete("tent")
			if ft == null or tent == null:
				_fail("foremans_tent/tent blueprint missing")
				return true
			if _zone.local_workers.size() != 4:
				_fail("tent auto-fill: residents %d != 4 after tent completed (2 + fill to capacity 4)" % _zone.local_workers.size())
				return true
			if not _api.adjust_job_target(1, "foreman", 1):
				_fail("foreman target adjust refused")
				return true
			_tick()
			# mouths=4: berries 50 -> eat 4 -> 46 -> capped yield min(6, 4) -> 50.
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
			# Housing cap: 4/4 (auto-filled by the tent) — any external
			# assign must be refused.
			var refused: bool = false
			for char_id in _api._registered_populants:
				if _api._registered_populants[char_id].assigned_node_id != 1:
					_api.recruit_populant_to_faction(char_id, "player")
					if _api.assign_populant_to_node(char_id, 1):
						_fail("housing cap: external assign PASSED at 4/4")
						return true
					refused = true
					break
			if not refused:
				_fail("no external populant available to test the housing cap")
				return true
			if _zone.local_workers.size() != 4:
				_fail("residents %d != 4 after cap enforcement" % _zone.local_workers.size())
				return true
			print("SMOKE: housing cap verified — 4/4 auto-filled, external assign refused")
			_stage = 7
		7:
			# Famine latch (#91 v3): zero production first (forager posting -> 0)
			# so the unfed tick can't be refilled in the same tick, then drain
			# food -> residents unfed -> latch closes at END of tick. The
			# unfed day also opens the ration debt ledger (4 residents).
			_api.adjust_job_target(1, "forager", -2)
			_zone.stockpile["Berries"] = 0
			_zone.stockpile["Mushrooms"] = 0
			_tick()
			if not _zone.famine_latched:
				_fail("famine: latch did not close after residents went unfed")
				return true
			if _zone.famine_deficit != 8:
				_fail("famine: entry deficit %d != 8 (4 residents x 2 debt rate)" % _zone.famine_deficit)
				return true
			print("SMOKE: famine latched — ration debt opened at 8")
			_stage = 8
		8:
			# Latched tick: everyone off the land; trickle 6/day (4 resting)
			# repays the debt FIRST — debt 4 -> +4 owed -> repay 6 -> 2 left
			# owed, NOTHING banks yet (negative balance grinding, #91 v3).
			_tick()
			if _zone._get_assigned_count("off_the_land") != 4:
				_fail("famine: expected 4 off the land, got %d" % _zone._get_assigned_count("off_the_land"))
				return true
			if _zone._get_assigned_count("forager") != 0:
				_fail("famine: foragers still manned")
				return true
			var food: int = _zone.stockpile.get("Berries", 0) + _zone.stockpile.get("Mushrooms", 0)
			if _zone.famine_deficit != 4:
				_fail("famine: deficit %d != 4 (8 owed + 8 accrued - 12 floor gross repaid)" % _zone.famine_deficit)
				return true
			if food != 0:
				_fail("famine: %d banked during debt repayment, expected 0" % food)
				return true
			if _zone.famine_latched == false:
				_fail("famine: unlatched while debt outstanding (position=%d)" % (food - _zone.famine_deficit))
				return true
			print("SMOKE: famine tick — 4 off the land, debt ground 8 -> 4 (floor gross 12/day), pantry still empty, org drained %d" % int(_zone.camp_organization))
			_stage = 9
		9:
			# Work through starvation (#92): order + cover an incomplete
			# building, toggle ON — 1 builder crawls at half speed, 3 rest.
			# Debt accrual (8) vs 3-resting floor gross (10) -> net +2/day:
			# recovery SLOWS but continues; the builder still crawls (+5).
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
			if _zone.famine_deficit != 2:
				_fail("work-through: deficit %d != 2 — accrual (8) vs floor gross (10): recovery must SLOW to +2/day with 1 builder" % _zone.famine_deficit)
				return true
			var food9: int = _zone.stockpile.get("Berries", 0) + _zone.stockpile.get("Mushrooms", 0)
			if food9 != 0:
				_fail("work-through: %d banked — recovery must stall while the toggle is ON" % food9)
				return true
			print("SMOKE: work-through verified — builder +5 labor, debt ground 4 -> 2 (slowed to +2/day), nothing banks")
			_stage = 10
		10:
			# Toggle OFF: the full grind — deficit 2 -> 0 at +4/day, then the
			# pantry banks +4/day to the 3x buffer (12).
			_api.toggle_work_through_famine(1, false)
			_grind = 0
			_stage = 11
		11:
			# Grind loop: debt repaid (deficit 2 -> 0), then the pantry banks
			# +4/day to the 3x buffer (12) and the latch OPENS.
			_tick()
			_grind += 1
			if not _zone.famine_latched:
				print("SMOKE: famine escaped after %d grind ticks — debt repaid + 3x buffer banked, workplaces re-manned" % _grind)
				_stage = 12
				return false
			if _grind >= 12:
				_fail("famine grind did not converge in 12 ticks (deficit=%d stock=%s)" % [
					_zone.famine_deficit, str(_zone.stockpile)])
				return true
			return false
		12:
			# Recovery: re-post foragers, normal tick re-mans workplaces from
			# postings; foreman regrows Organization from the drained level.
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
## Emits the REAL building_completed signal so completion side effects
## (tent auto-fill #91 v4) fire exactly as in play.
func _force_complete(building_id: String) -> Resource:
	var bp: Resource = load("res://data/blueprints/%s.tres" % building_id)
	if bp == null:
		return null
	for building in _zone.buildings:
		if building.blueprint.building_id == building_id:
			building.is_completed = true
			building.construction_progress = building.blueprint.total_work_required
			_zone.building_completed.emit(_zone.node_id, building_id)
			return building
	_api.order_building(1, bp)
	for building in _zone.buildings:
		if building.blueprint.building_id == building_id:
			building.is_completed = true
			building.construction_progress = building.blueprint.total_work_required
			_zone.building_completed.emit(_zone.node_id, building_id)
			return building
	return null

func _fail(reason: String) -> void:
	print("SMOKE: FAIL — " + reason)
	quit(1)
