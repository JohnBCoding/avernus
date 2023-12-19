extends Node

@onready var main_music = $main_music
@onready var death_music = $death_music

func _ready():
	add_to_group("audio")
	play_main()

func play_main():
	death_music.stop()
	main_music.play()
	
func play_dead():
	main_music.stop()
	death_music.play()
