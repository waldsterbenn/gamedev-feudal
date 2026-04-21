class_name PlayerState
extends State
# PlayerState.gd - Base for player-specific states

# 1. public vars
var player: Node

# 2. built-in callbacks
func _ready() -> void:
	super()
	
	# Find player by searching up the tree
	var current: Node = self
	while current:
		if current.is_in_group("player"):
			player = current
			break
		current = current.get_parent()
	
	if not player:
		push_error("PlayerState must be a child of a Player node in group 'player'")
