extends "mob.gd"

@onready var Burning = preload("res://src/buffs/burning.tscn")

func update_floor_mods(floor_num):
	add_to_group("demon")
	
	if floor_num >= 3:
		if randi_range(1, 100) <= mutate_chance:
			if randi_range(1, 100) <= prefix_chance:
				sprite.modulate = Color("#a13d3b")
				entity_name = "Helltouched " + entity_name
				entity_info = entity_info + "\nHelltouched: Living in Avernus has augmented this creature in unusual ways."
			elif randi_range(1, 100) <= suffix_chance:
				entity_name = entity_name + " Alpha"
				entity_info = entity_info + "\nAlpha: Strongest of their kind, an alpha won't be as easy to take down."
				health.update_max(2)

func tick():
	var player = get_tree().get_first_node_in_group("player")
	if entity_position.distance_to(player) == 1:
		if randi_range(1, 100) <= 50:
			path_to_player()
		else:
			bite_attack(player)
		return true
	if path_to_player():
		return true
	return false
	
func bite_attack(player):
	play_animation("attack")
	combat.deal_damage(self, player, "melee")
	var effects = get_tree().get_first_node_in_group("effect")
	effects.create_effect(player.entity_position.coords * 8)
	player.status.add_buff(Burning)
	var audio =  get_tree().get_first_node_in_group("audio")
	audio.play_destroy_vase()
	print("BITE BITE BITE", player)
