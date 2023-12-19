extends Node

@onready var Player = preload("res://src/player/player.tscn")
@onready var mob_spawn_table = [[preload("res://src/mobs/hell_rat.tscn"), 20], [preload("res://src/mobs/hell_bat.tscn"), 1]]
@onready var item_spawn_table = [
	[preload("res://src/items/shiv.tscn"), 10], [preload("res://src/items/wooden_shield.tscn"), 100], 
	[preload("res://src/items/blood_vial.tscn"), 10], [preload("res://src/items/meat_on_stick.tscn"), 10]]

func spawn_player(parent, pos):
	var player = Player.instantiate()
	parent.add_child(player)
	player.position = pos * 8
	player.entity_position.coords = Vector2(pos)
	
func spawn_mob(parent, pos):
	var total_weight = 0
	for spawn in mob_spawn_table:
		total_weight += spawn[1]
	var random_num = randi_range(0, total_weight-1)
	var random_mob = null
	for spawn in mob_spawn_table:
		if random_num < spawn[1]:
			random_mob = spawn[0]
			break
		else:
			random_num -= spawn[1]
	var mob = random_mob.instantiate()
	parent.add_child(mob)
	mob.position = pos * 8
	mob.entity_position.coords = Vector2(pos)

func spawn_random_item(parent, pos):
	if randi_range(1, 10) <= 10:
		var random_item = item_spawn_table[randi_range(0, len(item_spawn_table)-1)][0]
		var item = random_item.instantiate()
		parent.add_child(item)
		item.position = pos * 8
		item.entity_position.coords = Vector2(pos)
