extends "mob.gd"

func update_floor_mods(floor):
	if floor >= 3:
		if randi_range(1, 100) <= mutate_chance:
			if randi_range(1, 100) <= prefix_chance:
				sprite.modulate = Color("#a13d3b")
				entity_name = "Helltouched " + entity_name
				entity_info = entity_info + "\nHelltouched: Living in Avernus has augmented this creature in unusual ways."
			elif randi_range(1, 100) <= suffix_chance:
				entity_name = entity_name + " Alpha"
				entity_info = entity_info + "\nAlpha: Strongest of their kind, an alpha won't be as easy to take down."
				health.update_max(2)
	
