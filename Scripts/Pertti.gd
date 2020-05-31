extends KinematicBody2D

# Node references
onready var fireball = $Fireball
onready var hurt_sound = $Hurt
onready var explosion = $Explosion
onready var sprite = $Sprite
onready var animation = $Invinsibility
onready var camera = $Camera2D

# Signals
signal gameover
signal damage_taken
signal moved
signal respawn

# Scenes
var bullet = preload("res://Scenes/Bullet.tscn")

# Bools
var invinsibility = false
var gameover = false
var can_fire = true

# Others
var health = Settings.pertti_health
var movement = Vector2()

func _ready():
	connections()
	initial_invulnerability()

func _physics_process(delta):
	# Run _move if !gameover
	if !gameover:
		look_at(get_global_mouse_position())
	if !gameover:
		_move()
	# Run _fire if !gameover
	if Input.is_action_pressed("fire") and can_fire and !gameover and !get_parent().shop_panel.visible:
			_fire()

func initial_invulnerability():
	sprite.visible = true
	invinsibility = true
	animation.play("Invinsibility")
	yield(get_tree().create_timer(Settings.invinsibility), "timeout")
	invinsibility = false

func connections():
	connect("damage_taken", get_parent(), "_on_Pertti_damage_taken")
	connect("gameover", get_parent(), "_on_Pertti_gameover")
	connect("respawn", get_parent(), "_on_Pertti_respawn")

func _fire():
	# Create an instance based on a preloaded scene, then set its pos and rotation and apply an impulse
	fireball.play()
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
	movement.x += int(Input.is_action_pressed("right"))
	movement.x -= int(Input.is_action_pressed("left"))
	movement.y += int(Input.is_action_pressed("down"))
	movement.y -= int(Input.is_action_pressed("up"))
	
	movement = movement.normalized() * Settings.pertti_speed
	
	if movement != Vector2(0,0):
		emit_signal("moved")
	
	# Move Pertti
	move_and_slide(movement)
	movement = Vector2(0,0)

func _on_Area2D_body_entered(body):
	# Check for collisions with Enemies
	if "Enemy" in body.name and !gameover and !invinsibility and !("Tower" in body.name): 
		if health != 1:
			hurt_sound.play()
		health -= 1
		emit_signal("damage_taken", health)
		if health == 0:
			explosion.play()
			gameover = true
			emit_signal("gameover")
			yield(get_tree().create_timer(Settings.respawn_delay), "timeout")
			emit_signal("respawn")
			queue_free()
		invinsibility = true
		animation.play("Invinsibility")
		yield(get_tree().create_timer(Settings.invinsibility), "timeout")
		invinsibility = false
