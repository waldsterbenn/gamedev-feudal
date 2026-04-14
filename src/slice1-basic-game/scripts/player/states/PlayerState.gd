class_name PlayerState
extends State
# PlayerState.gd - Base for player-specific states

# 1. public vars
var player: Player:
	get:
		if not player:
			player = owner as Player
		return player

# 2. built-in callbacks
func _ready() -> void:
	super()
	await owner.ready
	if not player:
		push_error("PlayerState must be a child of a Player scene")
