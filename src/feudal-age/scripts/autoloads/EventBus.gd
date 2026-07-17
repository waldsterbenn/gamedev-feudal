extends Node

# Feudal domain events
signal domain_changed(new_domain_name: String)
signal vassal_loyalty_changed(vassal_name: String, new_loyalty: int)
signal gold_change_requested(delta: int)
signal gold_changed(new_amount: int)
signal prestige_change_requested(delta: int)
signal prestige_changed(new_prestige: int)
signal season_changed(season_index: int)
signal day_changed(new_day: int)
signal year_changed(new_year: int)
signal peasant_dispute_started(vassal_a: String, vassal_b: String)
signal npc_interacted(npc_name: String)

# Succession events
signal character_died(profile: VassalProfile)
signal succession_occurred(old_profile: VassalProfile, new_profile: VassalProfile)

# Petition events
signal petition_started(petitioner: Node3D, title: String, description: String, choices: Array[Dictionary])
signal petition_resolved(petitioner: Node3D, choice_index: int)

# Game state events
signal game_paused
signal game_resumed
signal level_loaded(level_name: String)
signal player_died

# UI events
signal message_logged(message: String, level: String)

# Management UI events
signal zone_selected(node_id: int)
signal zone_deselected()
signal management_mode_changed(is_active: bool)
