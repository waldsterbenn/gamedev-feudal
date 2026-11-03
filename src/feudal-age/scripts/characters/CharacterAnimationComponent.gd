# ============================================================================
# CharacterAnimationComponent — state-driven animation for KayKit characters.
# Owns the AnimationPlayer, merges clip libraries from the Rig_Medium anim
# GLBs onto the character skeleton (shared bone names, no retarget needed),
# and maps state machine state names to clips. States drive it exclusively
# through play_for_state()/play_clip(); it never queries its owner.
# Replaces the legacy PeasantCharacter.gd ("Take 001" loop) — issue #78.
# ============================================================================
class_name CharacterAnimationComponent
extends Node3D

signal animation_finished(anim_name: StringName)

const CLIP_IDLE := "Idle_A"
const CLIP_WALK := "Walking_A"
const CLIP_WORK := "Use_Item"
const CLIP_INTERACT := "Interact"

@export_file("*.glb") var library_paths: Array[String] = [
	"res://assets/characters/kaykit/Rig_Medium_General.glb",
	"res://assets/characters/kaykit/Rig_Medium_MovementBasic.glb",
]
## State machine node name -> clip name. Phase-level overrides call play_clip().
@export var state_clips: Dictionary = {
	"Idle": CLIP_IDLE,
	"Patrol": CLIP_WALK,
	"Work": CLIP_WALK,
	"AssignedWork": CLIP_WALK,
	"Interact": CLIP_INTERACT,
	# Player states (Player.gd wires state_changed -> play_for_state)
	"Moving": CLIP_WALK,
	"Jumping": "Jump_Full_Short",
}
## In-world units/second each clip is authored for; play_clip() scales playback
## as move_speed / reference so feet match ground speed. Falls back to
## reference_speed for clips not listed.
@export var clip_reference_speeds: Dictionary = {
	CLIP_WALK: 2.0,
	"Running_A": 4.0,
}
@export var looping_clips: Array[String] = [
	CLIP_IDLE, "Idle_B", CLIP_WALK, "Walking_B", "Walking_C",
	"Running_A", "Running_B", CLIP_WORK,
]
@export var blend_time: float = 0.2
## In-world units/second the walk clip is authored for; walk playback speed
## scales as move_speed / reference_speed when states pass their move speed.
@export var reference_speed: float = 2.0

@onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	_merge_clip_libraries()
	_apply_loop_modes()
	if _animation_player.animation_finished.is_connected(_on_animation_finished):
		pass
	else:
		_animation_player.animation_finished.connect(_on_animation_finished)
	if _animation_player.has_animation(CLIP_IDLE):
		play_clip(CLIP_IDLE)

## Plays the clip mapped to a state machine node name (signal-driven path).
func play_for_state(state_name: String) -> void:
	if state_clips.has(state_name):
		play_clip(state_clips[state_name])

## Plays a concrete clip. Pass move_speed (> 0) to sync walk playback to
## actual movement speed. Re-calling the current clip never restarts it;
## it only updates playback speed, so striding phase is preserved.
func play_clip(clip_name: String, move_speed: float = 0.0) -> void:
	if _animation_player == null or not _animation_player.has_animation(clip_name):
		return
	var speed_scale: float = 1.0
	if move_speed > 0.0:
		var reference: float = clip_reference_speeds.get(clip_name, reference_speed)
		if reference > 0.0:
			speed_scale = move_speed / reference
	if _animation_player.current_animation == clip_name:
		# Same-name play() keeps the current position (no restart) and
		# updates the per-clip custom speed. Do NOT touch the global
		# speed_scale — it would compound with the per-play custom speed.
		_animation_player.play(clip_name, blend_time, speed_scale)
		return
	_animation_player.play(clip_name, blend_time, speed_scale)

func get_animation_player() -> AnimationPlayer:
	return _animation_player

func _merge_clip_libraries() -> void:
	var library := AnimationLibrary.new()
	for path in library_paths:
		var packed: PackedScene = load(path) as PackedScene
		if packed == null:
			push_warning("AnimationComponent: missing clip library " + path)
			continue
		var inst: Node = packed.instantiate()
		var player := _find_animation_player(inst)
		if player == null:
			inst.free()
			continue
		for anim_name in player.get_animation_list():
			if not library.has_animation(anim_name):
				library.add_animation(anim_name, player.get_animation(anim_name))
		inst.free()
	if not _animation_player.has_animation_library(""):
		_animation_player.add_animation_library("", library)

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found:
			return found
	return null

func _apply_loop_modes() -> void:
	for clip_name in looping_clips:
		if _animation_player.has_animation(clip_name):
			_animation_player.get_animation(clip_name).loop_mode = Animation.LOOP_LINEAR

func _on_animation_finished(anim_name: StringName) -> void:
	animation_finished.emit(anim_name)
