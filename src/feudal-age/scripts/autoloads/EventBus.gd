extends Node

# Feudal domain events
signal domain_changed(new_domain_name: String)
signal vassal_loyalty_changed(vassal_name: String, new_loyalty: int)
signal gold_change_requested(delta: int)
signal gold_changed(new_amount: int)
signal prestige_changed(new_prestige: int)
signal season_changed(season_index: int)
signal peasant_dispute_started(vassal_a: String, vassal_b: String)
signal npc_interacted(npc_name: String)

# Game state events
signal game_paused
signal game_resumed
signal level_loaded(level_name: String)
signal player_died

# UI events
signal message_logged(message: String, level: String)
