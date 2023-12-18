extends Node2D

var parent
var skill_parent
var skill

func setup(parent_obj, skill_parent_obj, skill_obj):
	parent = parent_obj
	skill_parent = skill_parent_obj
	skill = skill_obj

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
