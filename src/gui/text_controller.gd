extends Node2D

@onready var Text = preload("res://src/gui/floating_text.tscn")

func _ready():
	add_to_group("text_controller")

func create_text(pos, text):
	var wait = false
	if get_child_count() > 0:
		wait = true
	var new_text = Text.instantiate()
	add_child(new_text)
	new_text.start(pos, text, wait)
	

