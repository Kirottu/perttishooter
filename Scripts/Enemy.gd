extends KinematicBody2D

signal destroyed

onready var nav_2d = $Navigation2D
onready var hurt_sound = $Hurt
onready var explosion = $Explosion

var rng = RandomNumberGenerator.new()
var health = Settings.enemy_health
var path
var pertti
var path_update_timer
var can_update = false
var pertti_in_sight = false
var path_length_to_pertti = 0 #set to 0 to force path calculation at start and because it crashes otherwise
var destroyed = false

func _ready():
	connect("destroyed", get_parent(), "_on_Enemy_destroyed")
	# Do not process right away as that would cause problems, randomize to unsync the calculation, and hopefully unstrain the cpu
	set_process(false)
	rng.randomize()
	path_update_timer = rng.randf_range(0, Settings.max_first_path_delay)
	

func _process(delta):
	# Look at pertti, looks  t h i c c
	# I see what you did arte, this incident will be reported
	# You just can't handle the truth, he do be dummy thicc
	# I wonder when valzu is gonna make the god damn wall textures
	look_at(pertti.position)
	
func _physics_process(delta):
	# Operate path update timer
	if path_update_timer <= 0 and !pertti_in_sight and health > 0:
		#can_update = true
		if can_update:
			update_path()
		#can_update = false
		path_update_timer = Settings.update_delay_factor * path_length_to_pertti
	else:
		path_update_timer -= 1
	
	if position.distance_to(pertti.position) <= Settings.close_proximity_follow_distance:
		pertti_in_sight = true
	else:
		pertti_in_sight = false
	if !pertti_in_sight and health != 0:
		move_along_path(Settings.enemy_speed * 0.02)
	# Switch to close proximity follow for better close quarters following
	elif health != 0:
		var start_point = position
		var direction = ( pertti.position - self.position).normalized()
		move_and_slide(direction * 500)
		# position = start_point.linear_interpolate(pertti.position, Settings.enemy_speed * 0.001 * delta)


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
			emit_signal("destroyed")
			yield(get_tree().create_timer(1.5), "timeout")
			# Queue for deletion in the next frame when health == 0
			queue_free()

func move_along_path(distance : float):
	# Set the start point of the path
	var start_point = position
	
	#updates length of route to pertti
	path_length_to_pertti -= distance
	
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

func set_pertti_ref(value):
	# Check if nothing was passed
	if value == null:
		print("no data provided")
		return
	# Debug messages
	#print(value)
	#print(position)
	pertti = value
	pertti.connect("gameover", self, "_on_Pertti_gameover")
	# Connect a signal to notify enemy to update path
	pertti.connect("moved", self, "pertti_moved_listener")
	path = nav_2d.get_simple_path(position, pertti.position)
	# Check if pathfinding was unsuccessful
	if path.size() == 0:
		return
	# Start _process function and start moving on the path
	set_process(true)
	#print("processing")

func pertti_moved_listener():
	can_update = true

func update_path():
	# Check if the can update timer has expired, as if this didnt exist the performance would be horrible all time pertto moves
	#if can_update:
	# Restart the timer
	#print("Path updating")
	# Recalculate the path
	path = nav_2d.get_simple_path(position, pertti.position)
	
	
	#recalculate the length of the route to pertti
	path_length_to_pertti = 0
	var last = pertti.position
	for i in range(1, path.size()):
		path_length_to_pertti += last.distance_to(path[i])
	if path_length_to_pertti * Settings.update_delay_factor <= Settings.minimum_path_delay:
		path_length_to_pertti =  Settings.minimum_path_delay / Settings.update_delay_factor
	# print(path_length_to_pertti * Settings.update_delay_factor)

func _on_Pertti_gameover():
	queue_free()
