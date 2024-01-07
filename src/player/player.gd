extends Node2D

@export var entity_name: String
@export var entity_position: Position
@export var health: Health
@export var sanity: Sanity
@export var combat: Combat
@export var equipment: Equipment
@export var status: Status
@onready var sprite = $sprite
@onready var animation_player = $animation_player
@onready var input_timer = $input_timer
var soulmarks = 0
var in_combat = false
var can_input = true
var audio = null

func _ready():
	add_to_group("player")
	status.buffs.push_back(load("res://src/buffs/buff.tscn").instantiate())
	status.calculate_stats(self)
	
	audio = get_tree().get_first_node_in_group("audio")

func handle_input():
	if can_input:
		# Movement
		var move_pos = Vector2.ZERO
		if Input.is_action_pressed("move_up"):
			move_pos = Vector2.UP
			start_input_timer()

		elif Input.is_action_pressed("move_right"):
			move_pos = Vector2.RIGHT
			sprite.flip_h = true
			start_input_timer()

		elif Input.is_action_pressed("move_down"):
			move_pos = Vector2.DOWN
			start_input_timer()

		elif Input.is_action_pressed("move_left"):
			move_pos = Vector2.LEFT
			sprite.flip_h = false
			start_input_timer()
			
		if move_pos != Vector2.ZERO:
			var blocker = entity_position.move(self, move_pos)
			if blocker:
				if typeof(blocker) == TYPE_VECTOR2I:
					var map = get_tree().get_first_node_in_group("map")
					if map.check_tile_interaction(entity_position.coords+move_pos, blocker):
						return "move"
				else:
					animation_player.play("attack")
					combat.deal_damage(self, blocker)
					var audio = get_tree().get_first_node_in_group("audio")
					audio.play_basic_hit()
					return "move"
			else:
				return "move"
				
		# Actions that use a turn
		if Input.is_action_just_pressed("grab"):
			# Check for using stairs
			var map = get_tree().get_first_node_in_group("map")
			if map.get_cell_atlas_coords(0, entity_position.coords) == map.TileType.STAIRS:
				map.next_floor()
			
			# Check picking up item
			for item in get_tree().get_nodes_in_group("item"):
				if item.entity_position.coords == entity_position.coords:
					var text_controller = get_tree().get_first_node_in_group("text_controller")
					text_controller.create_text(position, "+%s" % item.entity_name, "good", false)
					audio.play_pickup_item()
					if item.entity_name == "Soulmark":
						soulmarks += 1
						item.queue_free()
					else:
						if item.auto_use:
							item.use(self)
						else:
							item.pickup(self)
					return "pickup"
		
		elif Input.is_action_just_pressed("use_main"):
			if equipment.main_hand:
				equipment.use_main(self)
				return "equipment"
			
		elif Input.is_action_just_pressed("use_off"):
			if equipment.off_hand:
				equipment.use_off(self)
				return "equipment"
		
		# No cost actions
		if Input.is_action_just_pressed("cycle"):
			equipment.cycle()
			
		elif Input.is_action_just_pressed("info"):
			var world = get_tree().get_first_node_in_group("world")
			world.state = world.WorldState.Info
			
func start_input_timer():
	can_input = false
	input_timer.start()
	
func tick():
	sanity.tick(self)
	status.tick(self)


func _on_input_timer_timeout():
	can_input = true

func _on_animation_player_animation_finished(anim_name):
	if anim_name != "idle" && anim_name != "death":
		animation_player.play("idle")
	elif anim_name == "death":
		await get_tree().create_timer(2).timeout
		var map = get_tree().get_first_node_in_group("map")
		map.set_cell(0, entity_position.coords, 1, map.TileType.DEATH)
		visible = false
