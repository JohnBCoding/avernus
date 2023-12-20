extends Node

@onready var main_music = $main_music
@onready var death_music = $death_music
@onready var walk_sound = $walk_sound
@onready var basic_hit = $basic_hit_sound
@onready var player_damaged_sound = $player_damaged_sound
@onready var destroy_vase_sound = $destroy_vase_sound

func _ready():
	add_to_group("audio")
	play_main()

func play_main():
	death_music.stop()
	main_music.play()
	
func play_dead():
	main_music.stop()
	death_music.play()

func play_walk():
	walk_sound.play()

func stop_walk():
	walk_sound.stop()
	
func play_basic_hit():
	basic_hit.play()
	
func play_player_damaged():
	player_damaged_sound.play()
	
func play_destroy_vase():
	destroy_vase_sound.play()
