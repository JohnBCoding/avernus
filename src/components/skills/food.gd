extends "skill.gd"

@export var health_heal_amount: int
@export var sanity_heal_amount: int

func activate(parent, dir=null):
	parent.health.heal(health_heal_amount)
	parent.sanity.heal(sanity_heal_amount)
