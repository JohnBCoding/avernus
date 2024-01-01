extends "mob.gd"

var always_crit = false

func update_floor_mods(floor):
	if floor >= 3:
		if randi_range(1, 100) <= mutate_chance:
			if randi_range(1, 100) <= prefix_chance:
				sprite.modulate = Color("#a13d3b")
				entity_name = "Helltouched " + entity_name
				entity_info = entity_info + "\nHelltouched: Living in Avernus has augmented this creature in unusual ways."
				always_crit = true
			elif randi_range(1, 100) <= suffix_chance:
				entity_name = entity_name + " Alpha"
				entity_info = entity_info + "\nAlpha: Strongest of their kind, an alpha won't be as easy to take down."
				health.update_max(2)
				
func tick():
	var player = get_tree().get_first_node_in_group("player")
	if entity_position.distance_to(player) == 2:
		swoop_attack(player)
		return true
	if path_to_player():
		return true
	return false

func swoop_attack(player):
	var dir_to = position.direction_to(player.position)
	var new_pos = player.entity_position.coords - dir_to
	var map = get_tree().get_first_node_in_group("map")
	if map.walkable(new_pos):
		path_to_player()
		return
		
	play_animation("attack")
	var audio =  get_tree().get_first_node_in_group("audio")
	audio.play_destroy_vase()
	
	# Tween swoop towards player and "bounce" back off
	var tween = create_tween()
	entity_position.coords = new_pos
	tween.tween_property(self, "position", player.position, 0.2).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position", player.position-(dir_to*8), 0.1).set_trans(Tween.TRANS_BOUNCE)
	
	# Deal damage
	combat.deal_damage(self, player, "melee", always_crit)
