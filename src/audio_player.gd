extends Node

@onready var main_music = $main_music
@onready var death_music = $death_music
@onready var walk_sound = $walk_sound
@onready var basic_hit = $basic_hit_sound
@onready var player_damaged_sound = $player_damaged_sound
@onready var destroy_vase_sound = $destroy_vase_sound
@onready var open_chest_sound = $open_chest_sound
@onready var pickup_item_sound = $pickup_item_sound

func _ready():
	add_to_group("audio")
	play_main()

func stop_all_sounds():
	walk_sound.stop()
	basic_hit.stop()
	player_damaged_sound.stop()
	destroy_vase_sound.stop()
	
func play_main():
	death_music.stop()
	main_music.play()
	
func play_dead():
	main_music.stop()
	stop_all_sounds()
	death_music.play()

func play_walk():
	walk_sound.play()
	await get_tree().create_timer(0.2).timeout
	walk_sound.stop()
	
func play_pickup_item():
	pickup_item_sound.play()
	await get_tree().create_timer(0.2).timeout
	pickup_item_sound.stop()
	
func play_basic_hit():
	basic_hit.play()
	
func play_player_damaged():
	player_damaged_sound.play()
	
func play_destroy_vase():
	destroy_vase_sound.play()
	
func play_open_chest():
	open_chest_sound.play()
