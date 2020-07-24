extends Area2D

var exploded = false

func _on_Mine_body_entered(body):
	if "Pertti" in body.name or "Enemy" in body.name or "TowerEnemy" in body.name and !exploded:
		exploded = true
		body._hurt(10)
		$Sprite.visible = false
		$AnimatedSprite.visible = true
		$AnimatedSprite.play()
		$Explosion2.play()
		yield(get_tree().create_timer(0.7), "timeout")
		queue_free()
