extends PanelContainer

# Unique-name node references (set % on nodes in scene editor)
@onready var node_name_label: Label = %NodeNameLabel
@onready var tier_label: Label = %TierLabel
@onready var canopy_bar: ProgressBar = %CanopyBar
@onready var org_bar: ProgressBar = %OrgBar
@onready var famine_panel: PanelContainer = %FaminePanel
@onready var off_land_label: Label = %OffLandLabel
@onready var timber_label: Label = %TimberValueLabel
@onready var berries_label: Label = %BerriesValueLabel
@onready var mushrooms_label: Label = %MushroomsValueLabel
@onready var peasants_label: Label = %WorkersHeader
@onready var establish_camp_button: Button = %EstablishCampButton
@onready var build_button: Button = %BuildButton
@onready var cycle_blueprint_button: Button = %CycleBlueprintButton
@onready var blueprint_selection_label: Label = %BlueprintSelectionLabel
@onready var buildings_list_label: Label = %BuildingsListLabel
@onready var woodcutter_label: Label = %WoodcutterLabel
@onready var forager_label: Label = %ForagerLabel
@onready var builder_label: Label = %BuilderLabel
@onready var foreman_label: Label = %ForemanLabel
@onready var starving_label: Label = %StarvingLabel
@onready var famine_explain_label: Label = %FamineExplainLabel
@onready var work_through_button: Button = %WorkThroughButton
@onready var work_through_desc_label: Label = %WorkThroughDescLabel
@onready var post_forager_button: Button = %PostForagerButton
@onready var post_woodcutter_button: Button = %PostWoodcutterButton
@onready var post_foreman_button: Button = %PostForemanButton
@onready var close_button: Button = %CloseButton

## Composes button labels from the key-binding config (single source of truth)
func _apply_key_hints() -> void:
	var bindings: KeyBindingSet = load("res://data/ui/keybindings.tres")
	if bindings == null:
		return
	establish_camp_button.text = "⛺ Establish Work Camp  (%s)" % bindings.get_display("establish_camp")
	build_button.text = "🔨 Order Construction  (%s)" % bindings.get_display("order_building")
	cycle_blueprint_button.text = "🔁 Cycle Blueprint  (%s)" % bindings.get_display("cycle_blueprint")
	post_forager_button.text = "🌿 Forager +1  (%s / Shift+%s)" % [bindings.get_display("post_forager"), bindings.get_display("post_forager")]
	post_woodcutter_button.text = "🪵 Woodcutter +1  (%s / Shift+%s)" % [bindings.get_display("post_woodcutter"), bindings.get_display("post_woodcutter")]
	post_foreman_button.text = "🎖 Foreman +1  (%s / Shift+%s)" % [bindings.get_display("post_foreman"), bindings.get_display("post_foreman")]
	work_through_button.text = "⛏ Work through starvation: OFF  (%s)" % bindings.get_display("work_through")
	_wt_key_hint = bindings.get_display("work_through")
	close_button.text = "✕ Close  (%s)" % bindings.get_display("close_menu")

var _wt_key_hint: String = "T"

var _active_node_id: int = -1

## Slice blueprints the player can cycle and order (orderable in pinned scope #47)
const BLUEPRINT_PATHS: Array[String] = [
	"res://data/blueprints/tent.tres",
	"res://data/blueprints/forager_hut.tres",
	"res://data/blueprints/lumber_camp.tres",
	"res://data/blueprints/foremans_tent.tres",
]
var _blueprint_index: int = 0

func _ready() -> void:
	establish_camp_button.pressed.connect(_on_establish_camp_pressed)
	build_button.pressed.connect(_on_build_button_pressed)
	cycle_blueprint_button.pressed.connect(_cycle_blueprint)
	post_forager_button.pressed.connect(_on_post_forager_pressed)
	post_woodcutter_button.pressed.connect(_on_post_woodcutter_pressed)
	post_foreman_button.pressed.connect(_on_post_foreman_pressed)
	work_through_button.pressed.connect(_on_work_through_pressed)
	close_button.pressed.connect(_on_close_pressed)
	# Live refresh: the panel follows stockpile growth on every day tick
	EventBus.day_ticked.connect(_on_day_ticked)
	# Keyboard blueprint cycling / ordering (C and B keys emit the requests)
	EventBus.ui.blueprint_cycle_requested.connect(_cycle_blueprint)
	EventBus.ui.blueprint_order_requested.connect(_on_build_button_pressed)
	_apply_key_hints()

func open_inspection_window(node_id: int) -> void:
	EventBus.ui.debug("open_inspection_window node_id=" + str(node_id))
	_active_node_id = node_id
	_refresh_blueprint_selection()
	_refresh_display_metrics()

## Queries ManagementAPI and populates every display field
func _refresh_display_metrics() -> void:
	var api = ServiceLocator.get_management_service()
	if not api:
		return
	var data: Dictionary = api.get_node_inspection_data(_active_node_id)
	if data.is_empty():
		return

	node_name_label.text = data["node_name"]
	tier_label.text = data["tier_name"].capitalize()
	canopy_bar.value = data["canopy"] * 100.0
	# Camp Organization gauge (#91 v4): 0-100, mirrors the canopy bar
	org_bar.value = data.get("camp_organization", 0)
	# Per-resource stockpiling trend arrows (#92): ▲ building, ▼ draining
	var trends: Dictionary = data.get("stock_trends", {})
	timber_label.text = "%s 🪵 %d" % [_trend_arrow(trends, "Timber"), data["timber_stock"]]
	berries_label.text = "%s 🫐 %d" % [_trend_arrow(trends, "Berries"), data["berry_stock"]]
	mushrooms_label.text = "%s 🍄 %d" % [_trend_arrow(trends, "Mushrooms"), data["mushroom_stock"]]

	# Per-job rows show ASSIGNED / CAP where cap = completed-building slots
	# (#88): "wanted" targets no longer render — buildings define capacity.
	# Assignment buttons/rows hidden until the category's building exists —
	# a job cannot be posted into nothing (#90).
	var jobs: Dictionary = data["job_assignments"]
	var caps: Dictionary = data["job_caps"]
	var peasant_count: int = api.get_node_worker_count(_active_node_id)
	peasants_label.text = "👷 Peasants: %d" % peasant_count
	woodcutter_label.get_parent().visible = caps["woodcutter"] > 0
	woodcutter_label.text = "🪵 Woodcutter %d/%d" % [jobs["woodcutter"]["assigned"], caps["woodcutter"]]
	forager_label.get_parent().visible = caps["forager"] > 0
	forager_label.text = "🌿 Forager %d/%d" % [jobs["forager"]["assigned"], caps["forager"]]
	builder_label.text = "🔨 Builders %d (free workers, auto)" % jobs["builder"]["assigned"]
	foreman_label.get_parent().visible = caps["foreman"] > 0
	if jobs["foreman"]["assigned"] > 0:
		foreman_label.text = "🎖 Foreman %d/%d · Organization %d/100 → +%d%% resources" % [
			jobs["foreman"]["assigned"], caps["foreman"], data.get("camp_organization", 0), data.get("org_bonus_pct", 0)]
	else:
		foreman_label.text = "🎖 Foreman %d/%d · grows Organization +10/day (decays without one)" % [jobs["foreman"]["assigned"], caps["foreman"]]
	# Famine state block (#92): status, crawl progress, escape options.
	# The whole block lives in a FaminePanel box (readability, #91 v4) —
	# the panel is the single visibility writer for the block; inner
	# widgets toggle only their own extras.
	var latched: bool = data.get("famine_latched", false)
	# Famine rows (#91 v4.3): during famine ALL peasants live off the land,
	# so the other category rows would just read 0 — hide them, show only
	# the 🌾 row. The +1 post buttons stay (postings apply on recovery).
	if latched:
		woodcutter_label.get_parent().visible = false
		forager_label.get_parent().visible = false
		foreman_label.get_parent().visible = false
		builder_label.visible = false
	else:
		builder_label.visible = true
	var banked: int = data.get("famine_banked", 0)
	var needed: int = data.get("famine_needed", 0)
	var has_status: bool = latched or data.get("starving", 0) > 0
	famine_panel.visible = has_status
	starving_label.visible = has_status
	# "Living off the land" is a worker category during famine (#91) —
	# shown in the jobs list like woodcutter/forager/foreman, cap = all.
	off_land_label.get_parent().visible = latched
	if latched:
		off_land_label.text = "🌾 Living off the land %d/%d" % [
			data.get("famine", 0), data.get("worker_count", 0)]
	famine_explain_label.visible = latched
	work_through_button.visible = latched
	work_through_desc_label.visible = latched
	if latched:
		var deficit: int = data.get("famine_deficit", 0)
		var position: int = banked - deficit
		if deficit > 0:
			starving_label.text = "🌾 FAMINE — %d living off the land · ration debt %d" % [data.get("famine", 0), deficit]
		else:
			starving_label.text = "🌾 FAMINE — %d living off the land, workplaces unmanned!" % data.get("famine", 0)
		starving_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.3))
		famine_explain_label.text = "Workplaces unmanned, construction paused (except work-through). " \
			+ "The camp owes %d rations — foraging repays the debt first, then banks toward %d rations (%d/%d banked). " % [deficit, needed, position, needed] \
			+ "Only a clean ledger + full pantry ends the famine. Camp Organization drains daily."
		work_through_desc_label.text = "Cost: working builders forage almost nothing — each builder slows the ration-debt repayment by 2 rations/day, so recovery stalls (small camps) or crawls (large camps) while this is ON. Benefit: construction proceeds at half speed. Toggle OFF to let the camp grind out of debt fastest."
		work_through_button.text = "⛏ Work through starvation: %s  (%s)" % [
			"ON" if data.get("work_through_famine", false) else "OFF", _wt_key_hint]
	elif data.get("starving", 0) > 0:
		starving_label.text = "⚠ %d starving — assign foragers!" % data["starving"]
		starving_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.3))
	else:
		starving_label.text = ""

	# Per-building construction progress (#70)
	var lines: PackedStringArray = []
	for b in data["buildings"]:
		if b["completed"]:
			lines.append("✔ %s — complete" % b["name"])
		else:
			lines.append("🔨 %s — %d/%d" % [b["name"], int(b["progress"]), int(b["total"])])
	buildings_list_label.text = "\n".join(lines)

	# Show contextual action buttons based on settlement state. Job buttons
	# need BOTH a camp AND the category's completed building (#90) — caps
	# are 0 at wilderness anyway, so the cap gate covers both.
	var is_wilderness: bool = data["is_camp_creatable"]
	establish_camp_button.visible = is_wilderness
	build_button.visible = not is_wilderness
	# Assignment disabled during famine (#91 v4.3): the API hard-gates it;
	# buttons render greyed. Build/order stays allowed.
	cycle_blueprint_button.visible = not is_wilderness
	blueprint_selection_label.visible = not is_wilderness
	post_forager_button.visible = not is_wilderness and caps["forager"] > 0
	post_forager_button.disabled = latched
	post_woodcutter_button.disabled = latched
	post_foreman_button.disabled = latched
	post_woodcutter_button.visible = not is_wilderness and caps["woodcutter"] > 0
	post_foreman_button.visible = not is_wilderness and caps["foreman"] > 0

func _on_establish_camp_pressed() -> void:
	EventBus.ui.debug("Establish Camp pressed (node=" + " " + str(_active_node_id) + " " + ")")
	var api = ServiceLocator.get_management_service()
	if api:
		api.establish_camp(_active_node_id)
		_refresh_display_metrics()

func _on_post_forager_pressed() -> void:
	_post_job("forager", 1)

func _on_post_woodcutter_pressed() -> void:
	_post_job("woodcutter", 1)

func _on_post_foreman_pressed() -> void:
	_post_job("foreman", 1)

func _on_work_through_pressed() -> void:
	var api = ServiceLocator.get_management_service()
	if api and _active_node_id != -1:
		var data: Dictionary = api.get_node_inspection_data(_active_node_id)
		api.toggle_work_through_famine(_active_node_id, not data.get("work_through_famine", false))
		_refresh_display_metrics()

func _post_job(job_type: String, slots: int) -> void:
	EventBus.ui.debug("Post " + " " + str(job_type) + " " + " Job pressed (node=" + " " + str(_active_node_id) + " " + ")")
	var api = ServiceLocator.get_management_service()
	if api:
		var ok: bool = api.post_manual_job(_active_node_id, job_type, slots)
		EventBus.ui.debug("Post " + " " + str(job_type) + " " + " Job result: " + " " + str(ok))
		_refresh_display_metrics()

func _trend_arrow(trends: Dictionary, resource_name: String) -> String:
	var delta: int = int(trends.get(resource_name, 0))
	if delta > 0:
		return "▲"
	if delta < 0:
		return "▼"
	return "·"

func _on_build_button_pressed() -> void:
	if _active_node_id == -1:
		EventBus.ui.message_logged.emit("Open a zone inspection first (press 1-9, then Enter).", "warn")
		return
	var api = ServiceLocator.get_management_service()
	if not api:
		return
	var blueprint: BuildingData = _selected_blueprint()
	if blueprint == null:
		EventBus.ui.message_logged.emit("No blueprints available yet.", "warn")
		return
	EventBus.ui.debug("Attempted to order building (node=" + str(_active_node_id) + ")")
	var ok: bool = api.order_building(_active_node_id, blueprint)
	if ok:
		EventBus.ui.debug("Building order succeeded")
		_refresh_display_metrics()

## All three slice blueprints must be orderable (#68): the selection cycles
## through the list and the Order button applies the selected one.
func _selected_blueprint() -> BuildingData:
	var path: String = BLUEPRINT_PATHS[_blueprint_index % BLUEPRINT_PATHS.size()]
	if not ResourceLoader.exists(path):
		return null
	return load(path)

func _cycle_blueprint() -> void:
	_blueprint_index = (_blueprint_index + 1) % BLUEPRINT_PATHS.size()
	var blueprint: BuildingData = _selected_blueprint()
	if blueprint:
		EventBus.ui.debug("Blueprint selection cycled to " + blueprint.display_name)
		_refresh_blueprint_selection()

func _refresh_blueprint_selection() -> void:
	var blueprint: BuildingData = _selected_blueprint()
	if blueprint and blueprint_selection_label:
		blueprint_selection_label.text = "🔨 Selected: %s (🪵 %d)" % [blueprint.display_name, int(blueprint.build_cost.get("Timber", 0))]

func _on_close_pressed() -> void:
	EventBus.ui.zone_deselected.emit()

## Live-refresh while the panel is visible on each day tick
func _on_day_ticked(day: int) -> void:
	if _active_node_id != -1 and visible:
		_refresh_display_metrics()
