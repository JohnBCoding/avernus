extends "skill.gd"

func activate(parent, dir=null):
	parent.health.heal(5)
	parent.sanity.damage(3)
