extends RigidBody2D

onready var nav_2d = $Navigation2D
onready var hurt_sound = $Hurt
onready var explosion = $Explosion

var health = Settings.enemy_health
var path
var pertti
var path_update_timer = 30
var can_update = false
var pertti_in_sight = false

func _ready():
	# Do not process right away as that would cause problems
	set_process(false)

func _process(delta):
	# Look at pertti, looks funny
	look_at(pertti.position)
	
	# Set the enemy speed for the move_along_path function
	var move_distance = Settings.enemy_speed * delta
	if !pertti_in_sight:
		move_along_path(move_distance)
	else:
		var start_point = position
		position = start_point.linear_interpolate(pertti.position, move_distance * 0.005)
	
func _physics_process(delta):
	# Operate path update timer
	if path_update_timer == 0:
		can_update = true
		path_update_timer = 30
	if path_update_timer > 0:
		path_update_timer -= 1


func _on_Area2D_body_entered(body):
	# Check if a bullet has entered area, if so reduce health
	if "Bullet" in body.name:
		if health > 1:
			hurt_sound.play()
		health -= 1
		if health == 0:
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
	

func set_pertti_ref(value) -> void:
	# Check if nothing was passed
	if value == null:
		print("no data provided")
		return
	# Debug messages
	print(value)
	print(position)
	pertti = value
	# Connect a signal to notify enemy to update path
	pertti.connect("moved", self, "update_path")
	path = nav_2d.get_simple_path(position, pertti.position)
	# Check if pathfinding was unsuccessful
	if path.size() == 0:
		return
	# Start _process function and start moving on the path
	set_process(true)
	print("processing")

func update_path():
	# Check if the can update timer has expired, as if this didnt exist the performance would be horrible all time pertto moves
	if can_update:
		# Restart the timer
		can_update = false
		print("Path updated")
		# Recreate the path
		path = nav_2d.get_simple_path(position, pertti.position)

func _on_PerttiDetector_body_entered(body):
	if body.name == "Pertti":
		pertti_in_sight = true
	
func _on_PerttiDetector_body_exited(body):
	if body.name == "Pertti":
		pertti_in_sight = false
