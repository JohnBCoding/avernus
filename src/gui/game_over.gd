extends Control

var tween = null

func _process(_delta):
	var world = get_tree().get_first_node_in_group("world")
	if !tween:
		tween = create_tween()
		tween.tween_property(world, "modulate:a", 0.6, 2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		tween.tween_callback(on_tween_finished)
		
	if Input.is_action_just_pressed("use_main"):
		var map = get_tree().get_first_node_in_group("map")
		map.restart()
		world.modulate.a = 1
		
		world.state = world.WorldState.Tick
		get_tree().paused = false
		
		var audio = get_tree().get_first_node_in_group("audio")
		audio.play_main()
		
		queue_free()

func on_tween_finished():
	visible = true		
