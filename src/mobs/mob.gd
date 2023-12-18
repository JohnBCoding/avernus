extends Node2D

@export var entity_name: String
@export var entity_position: Position
@export var health: Health
@export var combat: Combat
@export var status: Status
@onready var sprite = $sprite

func _ready():
	add_to_group("mob")
	status.calculate_stats(self)
	
func tick():
	var map = get_tree().get_nodes_in_group("map")[0]
	var player = get_tree().get_nodes_in_group("player")[0]
	var path = map.find_path(entity_position.coords, player.entity_position.coords)
	#if entity_position.distance_to(player) < 10:
	if path:
		var dir = entity_position.coords.direction_to(path[1])
		var blocker = entity_position.move(self, dir)
		if blocker == player:
			combat.deal_damage(self, player)
			
		return true
	
	return false

