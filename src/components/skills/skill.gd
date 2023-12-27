extends Node

@export var skill_name: String
@export_multiline var skill_info: String
@export var requires_targeting: bool

func activate(parent, dir=null):
	print("GO!!!")
	print(dir)
