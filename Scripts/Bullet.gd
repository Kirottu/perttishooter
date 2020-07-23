extends RigidBody2D

func _on_Bullet_body_entered(body):
	if "Enemy" in body.name or body.name == "TileMap" or "Linus" in body.name: #Destroys bullet if it hits either a wall or an enemy
		queue_free()
