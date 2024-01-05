extends GPUParticles2D

func _ready():
	position += Vector2(4, 4)
	
func _on_finished():
	queue_free()
