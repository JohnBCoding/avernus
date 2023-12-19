extends Node2D

@onready var GameOver = preload("res://src/gui/game_over.tscn")
@onready var turn_queue = $turn_queue
	
func _process(_delta):
	var result = turn_queue.tick()
	if result == "game_over":
		var audio = get_tree().get_first_node_in_group("audio")
		audio.play_dead()
		turn_queue.reset()
		get_parent().get_node("gui").add_child(GameOver.instantiate())
		get_tree().paused = true
		
		
	
