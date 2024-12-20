extends Node2D

var parent
var skill_parent
var skill

func setup(parent_obj, skill_parent_obj, skill_obj):
	parent = parent_obj
	skill_parent = skill_parent_obj
	skill = skill_obj

func _draw():
	if parent && skill:
		var color = Color("#f9f5ef")
		color.a = 0.2
		for i in range(1, skill.get_skill_range(parent)+1):
			draw_rect(Rect2(-4, -4-(8*i), 8, 8), color, true)
			draw_rect(Rect2(-4+(8*i), -4, 8, 8), color, true)
			draw_rect(Rect2(-4, -4+(8*i), 8, 8), color, true)
			draw_rect(Rect2(-4-(8*i), -4, 8, 8), color, true)
		
func _process(_delta):
	var dir = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		dir = Vector2.UP

	elif Input.is_action_pressed("move_right"):
		dir = Vector2.RIGHT
		parent.sprite.flip_h = true

	elif Input.is_action_pressed("move_down"):
		dir = Vector2.DOWN

	elif Input.is_action_pressed("move_left"):
		dir = Vector2.LEFT
		parent.sprite.flip_h = false
		
	elif Input.is_action_just_pressed("cycle"):
		var turn_queue = get_tree().get_first_node_in_group("queue")
		turn_queue.remove(parent)
		turn_queue.insert(parent)
		get_tree().paused = false
		queue_free()
		
	if dir != Vector2.ZERO:
		skill.activate(parent, dir)
		if skill_parent.uses != -1:
			skill_parent.uses -= 1
			if skill_parent.uses <= 0:
				skill_parent.queue_free()
				
		get_tree().paused = false
		queue_free()
