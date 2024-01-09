extends Node

@onready var Burning = preload("res://src/effects/burning_effect.tscn")

func _ready():
	add_to_group("effect")

func create_effect(pos):
	var new_effect = Burning.instantiate()
	new_effect.position = pos
	add_child(new_effect)
	new_effect.emitting = true
