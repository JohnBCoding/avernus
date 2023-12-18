extends Node

@export var buff_name: String
@export var stats: Dictionary
@export var duration: int

func tick(_parent):
	if duration == -1:
		return
	
	duration -= 1
	if duration == 0:
		queue_free()
