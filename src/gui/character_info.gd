extends Control

@onready var nearby_label = $main/main_hbox/nearby_box/nearby_list

func _process(_delta):
	var world = get_tree().get_first_node_in_group("world")
	var nearby_str = ""
	var mobs = get_tree().get_nodes_in_group("mob")
	for mob in mobs:
		if mob.visible:
			nearby_str += "%s\n" % mob.entity_name
	nearby_label.text = nearby_str
	
	if Input.is_action_just_pressed("info"):
		world.state = world.WorldState.Tick
		get_tree().paused = false
		queue_free()
