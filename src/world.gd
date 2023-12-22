extends Node2D

@onready var turn_queue = $turn_queue

enum WorldState {
	Tick,
	Info,
	GameOver
}
var state = WorldState.Tick

func _ready():
	add_to_group("world")
	
func _process(_delta):
	match state:
		WorldState.Tick:
			turn_queue.tick()
		WorldState.Info:
			get_tree().paused = true
		WorldState.GameOver:
			var audio = get_tree().get_first_node_in_group("audio")
			audio.play_dead()
			turn_queue.reset()
			get_tree().paused = true
