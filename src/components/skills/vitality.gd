extends "skill.gd"

@export var boost_amount: int
@export var sanity_damage_amount: int

func activate(parent, _dir=null):
	parent.health.update_max(boost_amount)
	parent.sanity.damage(sanity_damage_amount)
