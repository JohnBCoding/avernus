extends Node
class_name Combat

@export var melee_damage: int
@export var armor: int
				
func deal_damage(parent, target, crit=false):
	var damage = parent.status.stats.melee_damage
	if crit:
		damage *= 2
	# Extra damage is added in after crit calculation
	damage += parent.status.stats.extra_damage
	target.combat.take_damage(target, damage)
	
func take_damage(parent, damage):
	var reduce_damage = max(0, damage - parent.status.stats.armor)
	if parent.health.damage(reduce_damage):
		if !parent.is_in_group("player"):
			parent.queue_free()
		
	if parent.is_in_group("player"):
		parent.sanity.tick(parent)
