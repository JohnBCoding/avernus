extends Node2D

@export var entity_name: String
@export_multiline var entity_info: String
@export var entity_position: Position
@export var Skill: PackedScene
@export var stats: Dictionary
@export var uses: int
@export var glow: bool
@onready var animation_player = $animation_player
@onready var Targeting = preload("res://src/gui/targeting.tscn")
var skill
var picked_up = false

func _ready():
	add_to_group("item")
	animation_player.play("spawn")
	if Skill:
		skill = Skill.instantiate()
		add_child(skill)

func drop(pos):
	visible = true
	entity_position.coords = pos
	position = entity_position.coords * 8
	picked_up = false
	
func pickup(parent):
	visible = false
	position = Vector2(-80, -80)
	entity_position.coords = Vector2(-1, -1)
	parent.equipment.equip(parent, self)
	picked_up = true

func use(parent):
	if skill:
		if skill.requires_targeting:
			var targeting = Targeting.instantiate()
			targeting.position += Vector2(4, 4)
			targeting.setup(parent, self, skill)
			parent.add_child(targeting)
			get_tree().paused = true
		else:
			skill.activate(parent)
	
			if uses != -1:
				uses -= 1
				if uses <= 0:
					queue_free()
					return false

	return true
		
	
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "spawn":
		if glow:
			animation_player.play("glow_idle")
		else:
			animation_player.play("idle")
