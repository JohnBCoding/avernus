extends "skill.gd"

@onready var effect = preload("res://src/effects/ranged_effect.tscn")

func activate(parent, dir=null):
	var map = get_tree().get_first_node_in_group("map")
	for i in range(1, parent.status.stats.attack_range+1):
		var blocker = map.walkable(parent.entity_position.coords + (dir * i))
		if blocker && typeof(blocker) != TYPE_VECTOR2I:
			var effect = effect.instantiate()
			effect.position = blocker.position + (dir * 8) + Vector2(4, 4)
			effect.rotation = parent.position.angle_to_point(blocker.position)
			parent.add_child(effect)
			effect.emitting = true
			parent.combat.deal_damage(parent, blocker, "ranged")
			var audio = get_tree().get_first_node_in_group("audio")
			audio.play_basic_hit()
			break
