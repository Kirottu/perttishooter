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
var health = Settings.npc_health
var path = []
var pertti
var seekingpertti = true
var path_update_timer
var path_length_to_pertti = 0 #set to 0 to force path calculation at start and because it crashes otherwise
var destination = Vector2(1000,600)

#func _ready():
	

func _process(delta):
	look_at(destination)

func _physics_process(delta):
	seekingpertti = position.distance_to(pertti.position) > Settings.npc_follow_pertti_treshold
	move()

func _on_pertti_moved():
	path.append(pertti.position)
	if seekingpertti:
		move_along_path(500)
		#destination = pertti.position
		

func set_pertti_ref(value):
	pertti = value
	pertti.connect("gameover", self, "_on_Pertti_gameover")
	pertti.connect("moved", self, "_on_pertti_moved")

func move_along_path(distance):
	var start_point = position
	path_length_to_pertti -= distance
	
	for i in range(path.size()):
		var distance_to_next = start_point.distance_to(path[0])
		if distance <= distance_to_next and distance > 0.0:
			position = start_point.linear_interpolate(path[0], distance / distance_to_next)
			break
		elif distance <= 0.0:
			position = path[0]
			break
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)

func move():
	var start_point = position
	print(self.position)
	var direction = (destination - self.position).normalized()
	move_and_slide(direction * 500)

func _on_Pertti_gameover():
	print("F")
	
func _on_Area2D_body_entered(body):
	# Check if a bullet has entered area, if so reduce health
	if "Enemy" in body.name and !destroyed and !seekingpertti:
		destination = body.get_position()
