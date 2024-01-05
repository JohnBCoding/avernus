extends Node

@export var buff_name: String
@export_multiline var buff_info: String
@export var stats: Dictionary
@export var duration: int

func tick(parent):
	if duration == -1:
		return
	
	duration -= 1
	if duration == 0:
		parent.status.buffs.erase(self)
		queue_free()
