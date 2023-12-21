extends "skill.gd"

func activate(parent, dir=null):
	var map = get_tree().get_first_node_in_group("map")
	var blocker = map.walkable(parent.entity_position.coords + dir)
	if blocker:
		if typeof(blocker) != TYPE_VECTOR2I:
			if blocker.is_in_group("mob"):
				parent.animation_player.play("pinpoint")
				parent.combat.deal_damage(parent, blocker, true)
				var audio = get_tree().get_first_node_in_group("audio")
				audio.play_basic_hit()
