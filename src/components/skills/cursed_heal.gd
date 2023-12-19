extends "skill.gd"

@export var health_heal_amount: int
@export var sanity_damage_amount: int

func activate(parent, dir=null):
	parent.health.heal(health_heal_amount)
	parent.sanity.damage(sanity_damage_amount)
