extends Node
class_name Combat

@export var melee_damage: int
@export var ranged_damage: int
@export var attack_range: int
@export var crit_chance: int
@export var armor: int

@onready var Burning = preload("res://src/buffs/burning.tscn")

func check_on_hit(parent, target, crit):
	if parent.status.stats.burn_chance > 0:
		if crit || randi_range(1, 100) <= parent.status.stats.burn_chance:
			var new_effect = load("res://src/effects/burning_effect.tscn").instantiate()
			new_effect.position = target.entity_position.coords * 8
			target.add_child(new_effect)
			new_effect.emitting = true
			target.status.add_buff(Burning)
		
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
	
	check_on_hit(parent, target, crit)
		
	# Extra damage is added in after crit calculation
	damage += parent.status.stats.extra_damage
	target.combat.take_damage(target, damage, "physical", crit)
	
func take_damage(parent, damage, damage_type, crit):
	var reduce_damage = 0
	match damage_type:
		"physical": reduce_damage = max(0, damage - parent.status.stats.armor)
		"fire": reduce_damage = max(0, damage)
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
