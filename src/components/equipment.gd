extends Node
class_name Equipment

var main_hand = null
var off_hand = null
var stackable = []

func equip(parent, item):
	if !main_hand:
		main_hand = item
	elif !off_hand:
		off_hand = item
	else:
		main_hand.drop(parent.entity_position.coords)
		main_hand = item
		
func cycle():
	var temp = main_hand
	main_hand = off_hand
	off_hand = temp

func use_main(parent):
	if is_instance_valid(main_hand):
		if !main_hand.use(parent):
			main_hand = null
	else:
		main_hand = null
		
func use_off(parent):
	if is_instance_valid(off_hand):
		if !off_hand.use(parent):
			off_hand = null
	else:
		off_hand = null
