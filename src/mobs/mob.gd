extends Node2D

@export var entity_name: String
@export_multiline var entity_info: String
@export var entity_position: Position
@export var health: Health
@export var combat: Combat
@export var status: Status
@export var IDLE_ANI: String
@export var ATTACK_ANI: String
@export var HIT_ANI: String
@export var DEATH_ANI: String
@onready var sprite = $sprite
@onready var animation_player = $animation_player
var level = 0

var item_drop_table = [["", 75], [preload("res://src/items/soulmark.tscn"), 25]]

func setup(map_pos, current_floor):
	add_to_group("mob")
	update_floor_mods(current_floor)
	status.calculate_stats(self)
	
	position = map_pos * 8
	entity_position.coords = Vector2(map_pos)

func update_floor_mods(_current_floor):
	pass
	
func play_animation(anim):
	match anim:
		"attack":
			animation_player.play(ATTACK_ANI)
		"hit":
			animation_player.play(HIT_ANI)
		"death":
			animation_player.play(DEATH_ANI)
			
func tick():
	if path_to_player():
		return true
	return false

func path_to_player():
	var map = get_tree().get_nodes_in_group("map")[0]
	var player = get_tree().get_nodes_in_group("player")[0]
	var path = map.find_path(entity_position.coords, player.entity_position.coords)
	if len(path) > 1:
		var dir = entity_position.coords.direction_to(path[1])
		# Flip sprite
		if dir == Vector2.RIGHT:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
			
		var blocker = entity_position.move(self, dir)
		if blocker == player:
			play_animation("attack")
			z_index = 200
			combat.deal_damage(self, player)
			
		return true
	return false
			
func _on_animation_player_animation_finished(anim_name):
	if anim_name != IDLE_ANI && anim_name != DEATH_ANI:
		if anim_name == HIT_ANI:
			if health.current_health <= 0:
				animation_player.play(DEATH_ANI)
				return
		elif anim_name == ATTACK_ANI:
			z_index = 1
		animation_player.play(IDLE_ANI)
	elif anim_name == DEATH_ANI:
		var map = get_tree().get_first_node_in_group("map")
		map.spawner.spawn_item_from_table(map, entity_position.coords, item_drop_table)
		queue_free()
