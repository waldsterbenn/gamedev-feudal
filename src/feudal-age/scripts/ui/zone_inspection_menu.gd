extends PanelContainer

# Unique-name node references (set % on nodes in scene editor)
@onready var node_name_label: Label = %NodeNameLabel
@onready var tier_label: Label = %TierLabel
@onready var canopy_bar: ProgressBar = %CanopyBar
@onready var timber_label: Label = %TimberValueLabel
@onready var berries_label: Label = %BerriesValueLabel
@onready var mushrooms_label: Label = %MushroomsValueLabel
@onready var workers_label: Label = %WorkersLabel
@onready var establish_camp_button: Button = %EstablishCampButton
@onready var build_button: Button = %BuildButton
@onready var close_button: Button = %CloseButton

var _active_node_id: int = -1

func _ready() -> void:
	establish_camp_button.pressed.connect(_on_establish_camp_pressed)
	build_button.pressed.connect(_on_build_button_pressed)
	close_button.pressed.connect(_on_close_pressed)
	# Auto-refresh stocks each day tick while panel is open
	EventBus.day_changed.connect(_on_day_changed)

func open_inspection_window(node_id: int) -> void:
	_active_node_id = node_id
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

	# Count workers from the raw ZoneNode for now
	var node_data: ZoneNode = api._world_nodes.get(_active_node_id)
	workers_label.text = str(node_data.local_workers.size()) + " workers" if node_data else "0 workers"

	# Show contextual action buttons based on settlement state
	var is_wilderness: bool = data["is_camp_creatable"]
	establish_camp_button.visible = is_wilderness
	build_button.visible = not is_wilderness

func _on_establish_camp_pressed() -> void:
	var api = ServiceLocator.get_management_service()
	if api:
		api.establish_camp(_active_node_id)
		_refresh_display_metrics()

func _on_build_button_pressed() -> void:
	# TODO (Phase 6 extension): Open a building-picker sub-panel
	# For now, attempt to order a tent as a placeholder
	var api = ServiceLocator.get_management_service()
	var tent_path := "res://data/blueprints/tent.tres"
	if api and ResourceLoader.exists(tent_path):
		var tent_blueprint: BuildingData = load(tent_path)
		if api.order_building(_active_node_id, tent_blueprint):
			_refresh_display_metrics()
	else:
		EventBus.message_logged.emit("No blueprints available yet.", "info")

func _on_close_pressed() -> void:
	EventBus.zone_deselected.emit()

## Auto-refresh while the panel is visible on each day change
func _on_day_changed(_new_day: int) -> void:
	if _active_node_id != -1 and visible:
		_refresh_display_metrics()
