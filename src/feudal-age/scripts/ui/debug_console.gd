extends PanelContainer
class_name DebugConsole

## Developer-only in-game log panel (right edge). Toggled with the
## "debug_overlay" key binding (default F12). Mirrors EventBus.ui.debug
## lines, day ticks, and player-facing messages with timestamps.

@onready var log_text: RichTextLabel = %DebugLogText
@onready var title_label: Label = %DebugTitle

var _bindings: KeyBindingSet

func _ready() -> void:
	_bindings = load("res://data/ui/keybindings.tres")
	title_label.text = "Debug Console  (%s)" % _bindings.get_display("debug_overlay")
	EventBus.ui.debug_line.connect(_on_debug_line)
	EventBus.ui.message_logged.connect(_on_message_logged)
	EventBus.day_ticked.connect(_on_day_ticked)
	EventBus.ui.management_mode_changed.connect(_on_mode_changed)
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == _bindings.get_key("debug_overlay"):
			visible = not visible
			get_viewport().set_input_as_handled()

func _on_debug_line(text: String) -> void:
	_append_line(text)

func _on_message_logged(message: String, level: String) -> void:
	_append_line("[%s] %s" % [level.to_upper(), message])

func _on_day_ticked(day: int) -> void:
	_append_line("--- Day %d ---" % day)

func _on_mode_changed(active: bool) -> void:
	_append_line("Management mode %s" % ("ON" if active else "off"))

func _append_line(text: String) -> void:
	var stamp := "[%s]" % Time.get_time_string_from_system().substr(0, 8)
	log_text.append_text("%s %s\n" % [stamp, text])
	log_text.scroll_to_line(log_text.get_line_count())