extends KinematicBody2D

func _on_Area2D_body_entered(body):
	
	if "Bullet" in body.name:
		queue_free()
