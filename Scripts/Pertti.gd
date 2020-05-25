extends KinematicBody2D

var fire_rate = Settings.fire_rate
var bullet_speed = Settings.bullet_speed
var bullet = preload("res://Scenes/Bullet.tscn")
var speed = Settings.pertti_speed
var movement = Vector2()

var can_fire = true

func _process(delta):
	look_at(get_global_mouse_position())
	

func _physics_process(delta):
	if Input.is_action_pressed("fire") and can_fire:
		_fire()
	if Input.is_action_pressed("right"):
		movement.x += speed
	if Input.is_action_pressed("left"):
		movement.x -= speed
	if Input.is_action_pressed("up"):
		movement.y -= speed
	if Input.is_action_pressed("down"):
		movement.y += speed
		
	move_and_slide(movement)
	movement.x = 0
	movement.y = 0

func _fire():
	var bullet_instance = bullet.instance()
	bullet_instance.position = $BulletPoint.get_global_position()
	bullet_instance.rotation_degrees = rotation_degrees 
	bullet_instance.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(rotation))
	get_tree().get_root().add_child(bullet_instance)
	can_fire = false
	yield(get_tree().create_timer(fire_rate), "timeout")
	can_fire = true
