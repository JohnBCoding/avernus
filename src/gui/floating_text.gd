extends Label

func start(pos, new_text, wait):
	var dy = Vector2(0, 28)
	if wait:
		await get_tree().create_timer(0.15).timeout
		dy.y -= 4
	
	position = pos
	dy = Vector2(position.x,0) if (position - dy).y < 0 else position - dy
	text = "%s" % new_text
	
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
