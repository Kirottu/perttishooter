extends KinematicBody2D

onready var nav_2d = $Navigation2D
onready var hurt_sound = $Hurt
onready var explosion = $Explosion

var health = Settings.enemy_health
var path
var pertti
var destroyed = false

func _ready():
	path = nav_2d.get_simple_path(position, Settings.tower_position)
#
func _process(delta):
	look_at(Settings.tower_position)
	
func _physics_process(delta):
	if  health > 0:
		move_along_path(Settings.enemy_speed * 0.02)
		# TODO: add case for when it's arrived, to optimize and stuff


func _on_Area2D_body_entered(body):
	# Check if a bullet has entered area, if so reduce health
	if "Bullet" in body.name and !destroyed:
		if health > 1:
			hurt_sound.play()
		if health > 0:
			health -= 1
		if health == 0:
			destroyed = true
			explosion.play()
			set_process(false)
			yield(get_tree().create_timer(1.5), "timeout")
			# Queue for deletion in the next frame when health == 0
			queue_free()

func move_along_path(distance : float):
	# Set the start point of the path
	var start_point = position
		
	# Loop trough the path array to move the enemy
	for i in range(path.size()):
		var distance_to_next = start_point.distance_to(path[0])
		if distance <= distance_to_next and distance > 0.0:
			# Move the enemy
			position = start_point.linear_interpolate(path[0], distance / distance_to_next)
			break
		elif distance <= 0.0:
			position = path[0]
			break
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)

