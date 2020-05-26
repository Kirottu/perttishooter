extends KinematicBody2D

signal gameover
signal damage_taken
signal moved

var bullet = preload("res://Scenes/Bullet.tscn")
var movement = Vector2()

var gameover = false
var can_fire = true
var health = Settings.pertti_health

func _process(delta):
	look_at(get_global_mouse_position())
	

func _physics_process(delta):
	if !gameover:
		_move()
	if !gameover:
		if Input.is_action_pressed("fire") and can_fire:
			_fire()

func _fire():
	var bullet_instance = bullet.instance()
	bullet_instance.position = $BulletPoint.get_global_position()
	bullet_instance.rotation_degrees = rotation_degrees 
	bullet_instance.apply_impulse(Vector2(), Vector2(Settings.bullet_speed, 0).rotated(rotation))
	get_tree().get_root().add_child(bullet_instance)
	can_fire = false
	yield(get_tree().create_timer(Settings.fire_rate), "timeout")
	can_fire = true

func _move():
	if Input.is_action_pressed("right"):
		movement.x = Settings.pertti_speed
	if Input.is_action_pressed("left"):
		movement.x = -Settings.pertti_speed
	if Input.is_action_pressed("up"):
		movement.y = -Settings.pertti_speed
	if Input.is_action_pressed("down"):
		movement.y = Settings.pertti_speed
	
	if movement != Vector2(0,0):
		emit_signal("moved")
	
	move_and_slide(movement)
	movement.x = 0
	movement.y = 0

func _on_Area2D_body_entered(body):
	if "Enemy" in body.name and !gameover: 
		health -= 1
		emit_signal("damage_taken", health)
		if health == 0:
			gameover = true
			emit_signal("gameover")
	
