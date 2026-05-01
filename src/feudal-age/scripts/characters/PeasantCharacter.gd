class_name PeasantCharacter
extends Node3D

signal animation_finished(anim_name: StringName)

@onready var _animation_player: AnimationPlayer

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

func play_animation(anim_name: String) -> void:
	if _animation_player and _animation_player.has_animation(anim_name):
		_animation_player.play(anim_name)

func get_animation_player() -> AnimationPlayer:
	return _animation_player

func _on_animation_finished(anim_name: StringName) -> void:
	animation_finished.emit(anim_name)
