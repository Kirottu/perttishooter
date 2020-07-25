extends Particles2D


func _ready():
	yield(get_tree().create_timer(5), "timeout")
	queue_free()
