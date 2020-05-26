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
	# Look at mouse pointer for aiming purposes
	look_at(get_global_mouse_position())
	

func _physics_process(delta):
	# Run _move if !gameover
	if !gameover:
		_move()
	# Run _fire if !gameover
	if !gameover:
		if Input.is_action_pressed("fire") and can_fire:
			_fire()

func _fire():
	# Create an instance based on a preloaded scene, then set its pos and rotation and apply an impulse
	var bullet_instance = bullet.instance()
	bullet_instance.position = $BulletPoint.get_global_position()
	bullet_instance.rotation_degrees = rotation_degrees 
	bullet_instance.apply_impulse(Vector2(), Vector2(Settings.bullet_speed, 0).rotated(rotation))
	get_tree().get_root().add_child(bullet_instance)
	can_fire = false
	# Wait until timeout
	yield(get_tree().create_timer(Settings.fire_rate), "timeout")
	can_fire = true

func _move():
	# Check for directional inputs
	if Input.is_action_pressed("right"):
		movement.x = Settings.pertti_speed
	if Input.is_action_pressed("left"):
		movement.x = -Settings.pertti_speed
	if Input.is_action_pressed("up"):
		movement.y = -Settings.pertti_speed
	if Input.is_action_pressed("down"):
		movement.y = Settings.pertti_speed
	
	# Tell enemies that Pertti has moved
	if movement != Vector2(0,0):
		emit_signal("moved")
	
	# Move Pertti
	move_and_slide(movement)
	movement.x = 0
	movement.y = 0

func _on_Area2D_body_entered(body):
	# Check for collisions with Enemies
	if "Enemy" in body.name and !gameover: 
		health -= 1
		emit_signal("damage_taken", health)
		if health == 0:
			gameover = true
			emit_signal("gameover")
	
