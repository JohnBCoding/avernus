extends Node
class_name Sanity

@export var base_sanity: int
@onready var sanity_buffs = [preload("res://src/buffs/buff.tscn"), preload("res://src/buffs/insane.tscn")]

var current_sanity = 0
var max_sanity = 0
var sanity_check = 0
var sane = true

func _ready():
	current_sanity = base_sanity
	max_sanity = base_sanity
	
	sanity_check = max_sanity / 2

func damage(amount):
	var adjusted_amount = max(0, current_sanity-amount)
	current_sanity = adjusted_amount
	var text_controller = get_tree().get_first_node_in_group("text_controller")
	text_controller.create_text(get_parent().position, "-%s SN" % amount)
	
func heal(amount):
	current_sanity += amount
	var text_controller = get_tree().get_first_node_in_group("text_controller")
	text_controller.create_text(get_parent().position, "+%s SN" % amount)
	
func tick(parent):
	if randi_range(1, 10) <= 2:
		if current_sanity > 0:
			current_sanity -= 1
			
	if current_sanity <= sanity_check && sane:
		print("Here")
		sane = false
		for buff in parent.status.buffs:
			if buff.buff_name == "sane":
				parent.status.buffs.erase(buff)
				break
		
		var buff = sanity_buffs[1].instantiate()
		parent.add_child(buff)
		parent.status.buffs.push_front(buff)
	elif current_sanity > sanity_check && !sane:
		sane = true
		for buff in parent.status.buffs:
			if buff.buff_name == "insane":
				parent.status.buffs.erase(buff)
				break
		
		var buff = sanity_buffs[0].instantiate()
		parent.add_child(buff)
		parent.status.buffs.push_front(buff)
