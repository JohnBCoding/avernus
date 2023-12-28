extends Control

@onready var character_box = $main/main_margin/main_vbox/main_hbox/character_box
@onready var equipment_box = $main/main_margin/main_vbox/main_hbox/equipment_box
@onready var status_box = $main/main_margin/main_vbox/main_hbox/status_box
@onready var nearby_box = $main/main_margin/main_vbox/main_hbox/nearby_box
@onready var info_name_label = $main/main_margin/main_vbox/info_box/info_name
@onready var info_label = $main/main_margin/main_vbox/info_box/info
@onready var info_stats_label = $main/main_margin/main_vbox/info_box/stats

var col_selected = 0
var row_selected = 0
var equip_list = []
var equip_labels = []
var buff_list = []
var buff_labels = []
var visible_list = []
var visible_labels = []


func _ready():
	var player = get_tree().get_first_node_in_group("player")
	for key in player.status.stats.keys():
		var new_label = Label.new()
		new_label.add_theme_font_size_override("font_size", 32)
		new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		new_label.text = "%s: %s" % [key.capitalize(), player.status.stats[key]]
		character_box.add_child(new_label)
	
	if player.equipment.main_hand:
		var new_label = Label.new()
		new_label.add_theme_font_size_override("font_size", 32)
		new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		new_label.text = "Main Hand: %s" % player.equipment.main_hand.entity_name
		equipment_box.add_child(new_label)
		equip_labels.push_back(new_label)
		equip_list.push_back(player.equipment.main_hand)
		
	if player.equipment.off_hand:
		var new_label = Label.new()
		new_label.add_theme_font_size_override("font_size", 32)
		new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		new_label.text = "Off Hand: %s" % player.equipment.off_hand.entity_name
		equipment_box.add_child(new_label)
		equip_labels.push_back(new_label)
		equip_list.push_back(player.equipment.off_hand)
		
	for buff in player.status.buffs:
		var new_label = Label.new()
		new_label.add_theme_font_size_override("font_size", 32)
		new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		new_label.text = buff.buff_name.capitalize()
		status_box.add_child(new_label)
		buff_labels.push_back(new_label)
		buff_list.push_back(buff)
		
	var mobs = get_tree().get_nodes_in_group("mob")
	for mob in mobs:
		if mob.visible:
			if mob not in visible_list:
				visible_list.push_back(mob)
	
	for entity in visible_list:
		var new_label = Label.new()
		new_label.add_theme_font_size_override("font_size", 32)
		new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		new_label.text = entity.entity_name
		nearby_box.add_child(new_label)
		visible_labels.push_back(new_label)
				
func _process(_delta):
	info_name_label.text = ""
	info_label.text = ""
	info_stats_label.text = ""
	
	match col_selected:
		0:
			character_box.modulate.a = 1
			equipment_box.modulate.a = 0.2
			status_box.modulate.a = 0.2
			nearby_box.modulate.a = 0.2
		1:
			equipment_box.modulate.a = 1
			character_box.modulate.a = 0.2
			status_box.modulate.a = 0.2
			nearby_box.modulate.a = 0.2
			
			for i in range(0, len(equip_labels)):
				equip_labels[i].modulate = Color("#f9f5ef")
				if i == row_selected:
					equip_labels[i].modulate = Color("#a13d3b")		
					
			# Show currently selected
			if len(equip_list) > 0:
				info_name_label.text = equip_list[row_selected].entity_name.capitalize()
				info_label.text = equip_list[row_selected].entity_info
				var stats_text = ""
				var skill = equip_list[row_selected].Skill.instantiate()
				var skill_text = "\n%s: %s" % [skill.skill_name, skill.skill_info]
				info_label.text += skill_text
				for key in equip_list[row_selected].stats.keys():
					stats_text += "%s %s%s | " % [key.capitalize(), "+" if equip_list[row_selected].stats[key] > 0 else "", equip_list[row_selected].stats[key]]
				info_stats_label.text = stats_text
		2:
			status_box.modulate.a = 1
			equipment_box.modulate.a = 0.2
			character_box.modulate.a = 0.2
			nearby_box.modulate.a = 0.2
			
			for i in range(0, len(buff_labels)):
				buff_labels[i].modulate = Color("#f9f5ef")
				if i == row_selected:
					buff_labels[i].modulate = Color("#a13d3b")		
					
			# Show currently selected
			if len(buff_list) > 0:
				info_name_label.text = buff_list[row_selected].buff_name.capitalize()
				info_label.text = buff_list[row_selected].buff_info
				var stats_text = ""
				for key in buff_list[row_selected].stats.keys():
					stats_text += "%s %s%s | " % [key.capitalize(), "+" if buff_list[row_selected].stats[key] > 0 else "", buff_list[row_selected].stats[key]]
				info_stats_label.text = stats_text
		3:
			nearby_box.modulate.a = 1
			equipment_box.modulate.a = 0.2
			character_box.modulate.a = 0.2
			status_box.modulate.a = 0.2
			
			for i in range(0, len(visible_labels)):
				visible_labels[i].modulate = Color("#f9f5ef")
				if i == row_selected:
					visible_labels[i].modulate = Color("#a13d3b")		
					
			# Show currently selected
			if len(visible_list) > 0:
				info_name_label.text = visible_list[row_selected].entity_name
				info_label.text = visible_list[row_selected].entity_info
			
	
	# Movement of col
	if Input.is_action_just_pressed("move_right"):
		col_selected += 1
		if col_selected > 3:
			col_selected = 0
		row_selected = 0
	elif Input.is_action_just_pressed("move_left"):
		col_selected -= 1
		if col_selected < 0:
			col_selected = 3
		row_selected = 0
	
	# Movement of row
	if Input.is_action_just_pressed("move_up"):
		row_selected -= 1
		if row_selected < 0:
			match col_selected:
				1:
					row_selected = len(equip_labels)-1
				2:
					row_selected = len(buff_labels)-1
				3:
					row_selected = len(visible_labels)-1
	elif Input.is_action_just_pressed("move_down"):
		row_selected += 1
		match col_selected:
			1:
				if row_selected > len(equip_labels)-1:
					row_selected = 0
			2:
				if row_selected > len(buff_labels)-1:
					row_selected = 0
			3:
				if row_selected > len(visible_labels)-1:
					row_selected = 0
			
	# Toggle info box
	var world = get_tree().get_first_node_in_group("world")
	if Input.is_action_just_pressed("info"):
		world.state = world.WorldState.Tick
		get_tree().paused = false
		queue_free()
