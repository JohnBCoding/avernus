extends Node
class_name Position

@onready var moving = false
@onready var coords = Vector2.ZERO

func move(parent, d_pos):
	if !moving:
		# Check if pos is walkable on the map
		var map = get_tree().get_nodes_in_group("map")[0]
		var blocker = map.walkable(coords + d_pos)
		
		# Move if free, we only return something if the path was blocked
		if !blocker:
			moving = true
			coords += d_pos
			
			# move
			var audio = get_tree().get_first_node_in_group("audio")
			audio.play_walk()
			move_tween(parent)
			
			# update visibility
			if parent.is_in_group("player"):
				map.fov.update_visibility(map.width, map.height, coords, parent.status.stats.sight_range)
				
		else:
			moving = true
			# bump tween
			var tween = create_tween()
			var original_position = parent.position
			parent.position = (coords * 8) + (d_pos * 4)
			tween.tween_property(parent, "position", original_position, 0.2).set_trans(Tween.TRANS_BACK)
			tween.tween_callback(on_tween_finished)
			
			# return blocker to be handled by parent
			return blocker

func distance_to(target):
	var target_pos = target.entity_position.coords
	return coords.distance_to(target_pos)
	
func move_tween(parent):
	var tween = create_tween()
	tween.tween_property(parent, "position", coords * 8, 0.2).set_trans(Tween.TRANS_BACK)
	tween.tween_callback(on_tween_finished)

func on_tween_finished():
	moving = false
	var audio = get_tree().get_first_node_in_group("audio")
	audio.stop_walk()
