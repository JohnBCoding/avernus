extends Control

var tween = null

func _process(_delta):
	if !tween:
		tween = create_tween()
		tween.tween_property(get_parent().get_parent(), "modulate:a", 0.6, 2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		tween.tween_callback(on_tween_finished)
		
	if Input.is_action_just_pressed("use_main"):
		var map = get_tree().get_first_node_in_group("map")
		map.restart()
		get_parent().get_parent().modulate.a = 1
		get_tree().paused = false
		
		var audio = get_tree().get_first_node_in_group("audio")
		audio.play_main()
		
		queue_free()

func on_tween_finished():
	visible = true
	print("tween done")
	print(visible)
		
