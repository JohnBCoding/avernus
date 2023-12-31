extends Label

func start(pos, new_text, type, big, wait, ):		
	match type:
		"good": modulate = Color("#f9f5ef")
		"bad": modulate = Color("#a13d3b")
		
	var dy = Vector2(0, 28)
	if wait:
		await get_tree().create_timer(0.15).timeout
		dy.y -= 4
	
	position = pos
	dy = Vector2(position.x,0) if (position - dy).y < 0 else position - dy
	text = "%s" % new_text
	
	# Scale tween
	# Scale quickly
	if big:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1, 0.75), 1.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
	# Movement tween
	# Movement should end before alpha
	var tween = create_tween()
	tween.tween_property(self, "position", dy, 1.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Alpha tween
	var tween2 = create_tween()
	tween2.tween_property(self, "modulate:a", 0.1, 2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween2.tween_callback(tween_completed)
	
func tween_completed():
	queue_free()
