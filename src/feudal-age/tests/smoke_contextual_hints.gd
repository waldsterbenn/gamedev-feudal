extends SceneTree
## Smoke: contextual key hints switch per UI state via EventBus signals.
## Stage-machine pattern over _process (matches smoke_slice.gd) — `await`
## does not resume inside _process in --script mode.

var _hints: Node = null
var _event_bus: Node = null
var _stage: int = 0

func _process(_delta: float) -> bool:
	match _stage:
		0:
			_hints = load("res://scripts/ui/contextual_key_hints.gd").new()
			root.add_child(_hints)
			_event_bus = root.get_node("EventBus")
			_stage = 1
		1:
			# State 1: HUD_ONLY — only the Tab entry hint
			var lines: Array[String] = _hints.get_hint_lines()
			if lines.size() != 1 or not lines[0].contains("Tab"):
				_fail("HUD_ONLY expected 1 Tab hint, got %s" % [str(lines)])
				return true
			print("SMOKE: HUD_ONLY -> " + " | ".join(lines))
			_event_bus.ui.management_mode_changed.emit(true)
			_stage = 2
		2:
			# State 2: management mode on — select/inspect hints appear
			var lines: Array[String] = _hints.get_hint_lines()
			if lines.size() != 3 or not lines[0].contains("Tab") or not "1-9" in lines[1]:
				_fail("MANAGEMENT expected 3 hints (Tab/1-9/Enter), got %s" % [str(lines)])
				return true
			print("SMOKE: MANAGEMENT -> " + " | ".join(lines))
			_event_bus.ui.zone_selected.emit(null)
			_stage = 3
		3:
			# State 3: zone selected — inspection open, only close hint
			var lines: Array[String] = _hints.get_hint_lines()
			if lines.size() != 1 or not lines[0].contains("Esc"):
				_fail("INSPECTING_NODE expected 1 Esc hint, got %s" % [str(lines)])
				return true
			print("SMOKE: INSPECTING_NODE -> " + " | ".join(lines))
			_event_bus.ui.zone_deselected.emit()
			_stage = 4
		4:
			# State 4: panel closed — falls back to MANAGEMENT (mode still active)
			var lines: Array[String] = _hints.get_hint_lines()
			if lines.size() != 3:
				_fail("after deselect expected MANAGEMENT fallback (3 hints), got %s" % [str(lines)])
				return true
			print("SMOKE: fallback -> " + " | ".join(lines))
			print("SMOKE: PASS")
			quit(0)
			return true
	return false

func _fail(reason: String) -> void:
	print("SMOKE: FAIL — " + reason)
	quit(1)
