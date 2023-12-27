extends "mob.gd"

func update_floor_mods(floor):
	if floor > 2:
		health.update_max(1)
