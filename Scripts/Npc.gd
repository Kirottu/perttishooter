extends KinematicBody2D

# Node references
onready var nav_2d = $Navigation2D
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
var destination = Vector2(1000,600)

func _ready():
	rng.randomize()
	connect("body_entered", self, "_on_seeing_something")

func _process(delta):
	look_at(destination)

func _physics_process(delta):
	seekingpertti = position.distance_to(pertti.position) > Settings.npc_follow_pertti_treshold
	if seekingpertti:
		destination = pertti.position 
	move(delta)

func set_pertti_ref(value):
	pertti = value
	pertti.connect("gameover", self, "_on_Pertti_gameover")
	#pertti.connect("moved", self, "_on_pertti_moved")

func move(delta):
	#move_and_slide(position.linear_interpolate(destination, delta * Settings.npc_speed))
	position = destination

func _on_Pertti_gameover():
	queue_free()
	
func _on_seeing_something(body):
	print("saw smth")
	if "Enemy" in body.name and !destroyed and !seekingpertti:
		destination = body.get_position()
		print("saw em")
