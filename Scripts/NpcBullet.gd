extends RigidBody2D

func _on_Bullet_body_entered(body):
	#Destroys bullet if it hits either a wall or an enemy
	if "Enemy" in body.name or "Linus" in body.name or "Pertti" in body.name or "TileMap" in body.name:
		queue_free()
