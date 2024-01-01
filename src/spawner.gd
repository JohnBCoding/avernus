extends Node

@onready var Player = preload("res://src/player/player.tscn")
@onready var mob_spawn_table = [[preload("res://src/mobs/hell_rat.tscn"), 20], [preload("res://src/mobs/hell_bat.tscn"), 3]]
@onready var base_item_spawn_table = [[preload("res://src/items/slingshot.tscn"), 5], [preload("res://src/items/shiv.tscn"), 15], [preload("res://src/items/preserved_insect.tscn"), 1],
	[preload("res://src/items/soulmark.tscn"), 5], [preload("res://src/items/blood_vial.tscn"), 1110], [preload("res://src/items/meat_on_stick.tscn"), 75]]
@onready var chest_item_spawn_table = [[preload("res://src/items/slingshot.tscn"), 10], [preload("res://src/items/wooden_shield.tscn"), 10], [preload("res://src/items/preserved_insect.tscn"), 15], 
	[preload("res://src/items/shiv.tscn"), 20]]

func spawn_player(parent, pos):
	var player = Player.instantiate()
	parent.add_child(player)
	player.position = pos * 8
	player.entity_position.coords = Vector2(pos)
	
func spawn_mob(parent, pos, floor):
	var random_mob = get_random_from_table(mob_spawn_table)
	var mob = random_mob.instantiate()
	parent.add_child(mob)
	mob.setup(pos, floor)

func spawn_random_item(parent, pos):
	var current_floor = get_tree().get_first_node_in_group("map").current_floor
	var item_chance = max(25, 100-(current_floor*4))
	if randi_range(1, 100) <= item_chance:
		var random_item = get_random_from_table(base_item_spawn_table)
		var item = random_item.instantiate()
		parent.add_child(item)
		item.position = pos * 8
		item.entity_position.coords = Vector2(pos)

func spawn_chest_item(parent, pos):
	spawn_item_from_table(parent, pos, chest_item_spawn_table)
	
func spawn_item_from_table(parent, pos, item_spawn_table):
	var random_item = get_random_from_table(item_spawn_table)
	if random_item:
		var item = random_item.instantiate()
		parent.add_child(item)
		item.position = pos * 8
		item.entity_position.coords = Vector2(pos)
	
func get_random_from_table(table):
	var total_weight = 0
	for spawn in table:
		total_weight += spawn[1]
	var random_num = randi_range(0, total_weight-1)
	var random_obj = null
	for spawn in table:
		if random_num < spawn[1]:
			random_obj = spawn[0]
			break
		else:
			random_num -= spawn[1]
	
	return random_obj
		
