extends Node
class_name Combat

@export var melee_damage: int
@export var ranged_damage: int
@export var crit_chance: int
@export var armor: int

func deal_damage(parent, target, attack_type="melee", crit=false):
	var damage = 0
	match attack_type:
		"melee":
			damage = parent.status.stats.melee_damage
		"ranged":
			damage = parent.status.stats.ranged_damage
			
	if crit:
		# Check if this damage is forced to crit, usually from a skill/effect.
		damage *= 2
	else:
		# Check for crit
		if randi_range(1, 100) <= parent.status.stats.crit_chance:
			damage *= 2
			crit = true
		
	# Extra damage is added in after crit calculation
	damage += parent.status.stats.extra_damage
	target.combat.take_damage(target, damage, crit)
	
func take_damage(parent, damage, crit):
	var reduce_damage = max(0, damage - parent.status.stats.armor)
	if parent.health.damage(reduce_damage, crit):
		if !parent.is_in_group("player"):
			parent.play_animation("death")
		
	if parent.is_in_group("player"):
		parent.sanity.tick(parent)
		parent.animation_player.play("hit")
		var audio =  get_tree().get_first_node_in_group("audio")
		audio.play_player_damaged()
	else:
		parent.play_animation("hit")
