extends Node
class_name Health

@export var base_health: int
var current_health = 0
var max_health = 0

func _ready():
	current_health = base_health
	max_health = base_health

func damage(amount):
	current_health = max(0, current_health-amount)
	
	var text_controller = get_tree().get_first_node_in_group("text_controller")
	text_controller.create_text(get_parent().position, "-%s" % amount)
	
	# return true if dead
	if current_health == 0:
		return true
		
	return false
		
func heal(amount):
	var adjusted_amount = min(current_health + amount, max_health)
	var amount_healed = adjusted_amount - current_health
	current_health = adjusted_amount
	
	var text_controller = get_tree().get_first_node_in_group("text_controller")
	text_controller.create_text(get_parent().position, "+%s HP" % amount_healed)
	
func update_max(amount):
	current_health += amount
	max_health += amount
	
	var text_controller = get_tree().get_first_node_in_group("text_controller")
	text_controller.create_text(get_parent().position, "+%s MAX HP" % amount)
