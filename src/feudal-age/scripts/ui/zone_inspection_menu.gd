extends PanelContainer

# Unique-name node references (set % on nodes in scene editor)
@onready var node_name_label: Label = %NodeNameLabel
@onready var tier_label: Label = %TierLabel
@onready var canopy_bar: ProgressBar = %CanopyBar
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
@onready var post_forager_button: Button = %PostForagerButton
@onready var post_woodcutter_button: Button = %PostWoodcutterButton
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
	close_button.text = "✕ Close  (%s)" % bindings.get_display("close_menu")

var _active_node_id: int = -1

## Slice blueprints the player can cycle and order (orderable in pinned scope #47)
const BLUEPRINT_PATHS: Array[String] = [
	"res://data/blueprints/tent.tres",
	"res://data/blueprints/forager_post.tres",
	"res://data/blueprints/charcoal_stack.tres",
]
var _blueprint_index: int = 0

func _ready() -> void:
	establish_camp_button.pressed.connect(_on_establish_camp_pressed)
	build_button.pressed.connect(_on_build_button_pressed)
	cycle_blueprint_button.pressed.connect(_cycle_blueprint)
	post_forager_button.pressed.connect(_on_post_forager_pressed)
	post_woodcutter_button.pressed.connect(_on_post_woodcutter_pressed)
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
	timber_label.text = "🪵 " + str(data["timber_stock"])
	berries_label.text = "🫐 " + str(data["berry_stock"])
	mushrooms_label.text = "🍄 " + str(data["mushroom_stock"])

	# Per-job worker assignment rows (#73): Peasants tally lives ONLY in the
	# lower workers section — "Peasants" = sum of all assignees (woodcutter
	# + forager + builders). Unassigned peasants tally as builders while
	# construction runs (ZoneNode._resolve_workforce_allocation).
	var jobs: Dictionary = data["job_assignments"]
	var peasant_count: int = jobs["woodcutter"]["assigned"] + jobs["forager"]["assigned"] + jobs["builder"]["assigned"]
	peasants_label.text = "👷 Peasants: %d" % peasant_count
	woodcutter_label.text = "🪵 Woodcutter %d assigned / %d wanted" % [jobs["woodcutter"]["assigned"], jobs["woodcutter"]["target"]]
	forager_label.text = "🌿 Forager %d assigned / %d wanted" % [jobs["forager"]["assigned"], jobs["forager"]["target"]]
	builder_label.text = "🔨 Builders %d (free workers, auto)" % jobs["builder"]["assigned"]

	# Per-building construction progress (#70)
	var lines: PackedStringArray = []
	for b in data["buildings"]:
		if b["completed"]:
			lines.append("✔ %s — complete" % b["name"])
		else:
			lines.append("🔨 %s — %d/%d" % [b["name"], int(b["progress"]), int(b["total"])])
	buildings_list_label.text = "\n".join(lines)

	# Show contextual action buttons based on settlement state
	var is_wilderness: bool = data["is_camp_creatable"]
	establish_camp_button.visible = is_wilderness
	build_button.visible = not is_wilderness
	cycle_blueprint_button.visible = not is_wilderness
	blueprint_selection_label.visible = not is_wilderness
	post_forager_button.visible = not is_wilderness
	post_woodcutter_button.visible = not is_wilderness

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

func _post_job(job_type: String, slots: int) -> void:
	EventBus.ui.debug("Post " + " " + str(job_type) + " " + " Job pressed (node=" + " " + str(_active_node_id) + " " + ")")
	var api = ServiceLocator.get_management_service()
	if api:
		var ok: bool = api.post_manual_job(_active_node_id, job_type, slots)
		EventBus.ui.debug("Post " + " " + str(job_type) + " " + " Job result: " + " " + str(ok))
		_refresh_display_metrics()

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
