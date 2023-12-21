extends "mob.gd"

var always_crit = false

func update_floor_mods(floor):
	if floor > 2:
		health.update_max(1)
	
	if floor > 3:
		always_crit = true
		
func tick():
	var player = get_tree().get_first_node_in_group("player")
	if entity_position.distance_to(player) == 2:
		swoop_attack(player)
		return true
	if path_to_player():
		return true
	return false


func swoop_attack(player):
	play_animation("attack")
	var audio =  get_tree().get_first_node_in_group("audio")
	audio.play_destroy_vase()
	
	# Tween swoop towards player and "bounce" back off
	var tween = create_tween()
	var dir_to = position.direction_to(player.position)
	entity_position.coords = player.entity_position.coords - dir_to
	tween.tween_property(self, "position", player.position, 0.2).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position", player.position-(dir_to*8), 0.1).set_trans(Tween.TRANS_BOUNCE)
	
	# Deal damage
	combat.deal_damage(self, player, always_crit)
