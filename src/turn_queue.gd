extends Node

@onready var ani_timer = $ani_timer
var queue_ready = false
var map = null
var queue = []
var current = null

func _ready():
	add_to_group("queue")

func insert(entity):
	queue.push_front(entity)
	
func add(entity):
	queue.push_back(entity)
	
func remove(entity):
	queue.erase(entity)

func reset():
	queue_ready = false
	queue = []
	current = null
	
	
func init(_map):
	map = _map
	var player = get_tree().get_first_node_in_group("player")
	var mobs = get_tree().get_nodes_in_group("mob")
	for mob in mobs:
		add(mob)

	current = player
	queue_ready = true
		
func next_turn():
	if is_instance_valid(current):
		add(current)
	current = null
	map.calculate_astar()
	ani_timer.start()

func tick():
	if current && queue_ready:
		if is_instance_valid(current):
			if current.is_in_group("player"):
				# Game over
				if current.health.current_health <= 0:
					current.animation_player.play("death")
					return "game_over"
				
				# Get action otherwise
				var action = await current.handle_input()
				if action:
					current.tick()
					if current.in_combat:
						ani_timer.wait_time = 0.25
					else:
						ani_timer.wait_time = 0.0001
					next_turn()
			else: # AI
				# Current don't process anything that isn't in the FOV
				if current.visible && current.health.current_health > 0:
					# If tick is true, ai did something so wait for animation
					# otherwise, don't wait
					if current.tick():
						ani_timer.wait_time = 0.15
					else:
						ani_timer.wait_time = 0.0001
				else:
					if current.health.current_health > 0:
						ani_timer.wait_time = 0.0001
					else:
						ani_timer.wait_time = 0.4
				next_turn()
		else:
			remove(current)
			next_turn()

func _on_ani_timer_timeout():
	current = queue.pop_front()
