extends KinematicBody2D

# Scenes
var bullet = preload("res://Scenes/Bullet.tscn")

# Node references
onready var hurt_sound = $Hurt
onready var explosion = $Explosion
onready var sprite = $Sprite

# Bools
var can_update = false
var enemy_in_sight = false
var destroyed = false

# Signals
signal destroyed

# Misc
var rng = RandomNumberGenerator.new()
var seekingpertti = true
var pertti
var direction
var destination

func _ready():
	rng.randomize()

func _physics_process(delta):
	if position.distance_to(pertti.position) > Settings.npc_follow_pertti_treshold:
		seekingpertti = true
		move()
	else:
		seekingpertti = false

func set_pertti_ref(value):
	pertti = value
	pertti.connect("gameover", self, "_on_Pertti_gameover")
	#pertti.connect("moved", self, "_on_pertti_moved")

func move():
	#move_and_slide(position.linear_interpolate(destination, delta * Settings.npc_speed))
	direction = (pertti.position - position).normalized()
	move_and_slide(direction * Settings.npc_speed)

func _on_Pertti_gameover():
	queue_free()

func _on_Area2D_body_entered(body):
	print("saw smth")
	if "Enemy" in body.name and !destroyed and !seekingpertti:
		print("saw em")
