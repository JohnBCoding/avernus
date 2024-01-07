extends Control

@onready var GameOver = preload("res://src/gui/game_over.tscn")
@onready var CharacterInfo = preload("res://src/gui/character_info.tscn")

@onready var class_label = $parent/main/main_hbox/character/class
@onready var health_label = $parent/main/main_hbox/character/details/status/health
@onready var sanity_label = $parent/main/main_hbox/character/details/status/sanity
@onready var main_label = $parent/main/main_hbox/character/details/equipment/main_hand
@onready var off_label = $parent/main/main_hbox/character/details/equipment/off_hand
@onready var buffs_label = $parent/main/main_hbox/status/buff_container/buffs
@onready var info_name = $parent/main/main_hbox/info/name
@onready var info_info = $parent/main/main_hbox/info/info
@onready var info_tags = $parent/main/main_hbox/info/tags
@onready var floor_label = $parent/main/main_hbox/character/other_details/floor
@onready var soulmarks_label = $parent/main/main_hbox/character/other_details/soulmarks

func _process(delta):
	var world = get_tree().get_first_node_in_group("world")
	match world.state:
		world.WorldState.Tick:
			modulate.a = 1
		world.WorldState.Info:
			modulate.a = 0.1
			add_child(CharacterInfo.instantiate())
		world.WorldState.GameOver:
			add_child(GameOver.instantiate())
			
	var player = get_tree().get_first_node_in_group("player")
	if player:
		class_label.text = player.entity_name
		health_label.text = "Health: %s/%s" % [player.health.current_health, player.health.max_health]
		sanity_label.text = "Sanity: %s/%s" % [player.sanity.current_sanity, player.sanity.sanity_check]
		
		if is_instance_valid(player.equipment.main_hand):
			main_label.text = "Main Hand(Z): %s" % [player.equipment.main_hand.entity_name]
		else:
			main_label.text = "Main Hand(Z): None"
			
		if is_instance_valid(player.equipment.off_hand):
			off_label.text = "Off Hand(X): %s" % [player.equipment.off_hand.entity_name]
		else:
			off_label.text = "Off Hand(X): None"
		
		var buff_text = ""
		for buff in player.status.buffs:
			buff_text += "%s " % buff.buff_name.capitalize()
		buffs_label.text = buff_text
		
		# show info if player is standing on something
		info_name.text = "Ground"
		info_info.text = "Yep, thats the ground."
		info_tags.text = ""
		for item in get_tree().get_nodes_in_group("item"):
			if player.entity_position.coords == item.entity_position.coords:
				info_name.text = item.entity_name
				info_info.text = item.entity_info
				if item.skill:
					info_tags.text = "%s %s" % [item.skill.skill_name, "Targeted" if item.skill.requires_targeting else ""]
				if item.auto_use:
					info_tags.text += "Stackable"
					
				break
		
		# Update soulmarks
		soulmarks_label.text = "Soulmarks: %s" % player.soulmarks
		
		# show map floor
		var map = get_tree().get_first_node_in_group("map")
		floor_label.text = "Floor %s" % map.current_floor
