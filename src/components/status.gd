extends Node
class_name Status

var stats = {}
var buffs = []

func tick(parent):
	calculate_stats(parent)
	for buff in buffs:
		buff.tick(parent)

func calculate_stats(parent):
	# Base
	stats = {
		health = parent.health.max_health,
		sanity_threshold = parent.sanity.sanity_check if parent.is_in_group("player") else 0,
		sight_range = 4,
		attack_range = 0,
		melee_damage = parent.combat.melee_damage,
		ranged_damage = parent.combat.ranged_damage,
		extra_damage = 0,
		crit_chance = parent.combat.crit_chance,
		armor = parent.combat.armor
	}
	
	# Calculate equipment
	if parent.is_in_group("player"):
		var equipment = [parent.equipment.main_hand, parent.equipment.off_hand]
		for equip in equipment:
			if is_instance_valid(equip):
				for key in equip.stats.keys():
					stats[key] += equip.stats[key]
					
	# Calculate buffs
	for buff in buffs:
		for key in buff.stats.keys():
			stats[key] += buff.stats[key]
