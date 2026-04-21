class_name PeasantCharacter
extends Node3D

# 1. signals
signal animation_finished(anim_name: StringName)

# 2. onready
@onready var _animation_player: AnimationPlayer

# 3. built-in callbacks
func _ready() -> void:
	var fbx_root: Node = get_child(0)
	if fbx_root:
		_animation_player = fbx_root.get_node_or_null("AnimationPlayer") as AnimationPlayer
		if _animation_player:
			_animation_player.animation_finished.connect(_on_animation_finished)
			var anim: Animation = _animation_player.get_animation("Take 001")
			if anim:
				anim.loop_mode = Animation.LOOP_LINEAR
			play_animation("Take 001")

# 4. public functions
func play_animation(anim_name: StringName) -> void:
	if _animation_player and _animation_player.has_animation(anim_name):
		_animation_player.play(anim_name)

func get_animation_player() -> AnimationPlayer:
	return _animation_player

# 5. private functions
func _on_animation_finished(anim_name: StringName) -> void:
	animation_finished.emit(anim_name)
