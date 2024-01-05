extends "buff.gd"

func tick(parent):
	if duration == -1:
		duration = parent.status.stats.armor
	
	parent.combat.take_damage(parent, 1, "fire", false)
	var new_effect = load("res://src/effects/burning_effect.tscn").instantiate()
	new_effect.position = parent.entity_position.coords * 8
	parent.add_child(new_effect)
	new_effect.emitting = true
	duration -= 1
	if duration == 0:
		parent.status.buffs.erase(self)
		queue_free()


