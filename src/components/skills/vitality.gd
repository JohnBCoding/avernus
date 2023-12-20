extends "skill.gd"

@export var boost_amount: int

func activate(parent, dir=null):
	parent.health.update_max(boost_amount)
