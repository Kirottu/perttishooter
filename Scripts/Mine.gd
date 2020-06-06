extends RigidBody2D

func detonated():
	# here should be a cool animation and stuff, if only the artists would get their lazy asses working :helpmeplz:
	queue_free()

func _on_Area2D_body_entered(body):
	match body.name:
		"Enemy", "Pertti":
			print("boom")
			print(body.name)
			body._hurt(Settings.mine_damage)
			detonated()
		"Bullet":
			detonated()
