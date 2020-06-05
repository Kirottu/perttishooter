extends RigidBody2D

func _on_triggered(body):
	if body.name != "TileMap": #Destroys bullet if it hits either a wall or an enemy
		queue_free()
