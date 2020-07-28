extends KinematicBody2D

var blood_scene = preload("res://Scenes/Blood.tscn")

# Node references
onready var nav_2d = $Navigation2D
onready var hurt_sound = $Hurt
onready var explosion = $Explosion
onready var sprite = $Sprite
onready var tilemap = $Navigation2D/TileMap
#onready var line = Line2D.new()

# Bools
var can_update = false
var pertti_in_sight = false
var destroyed = false
var path_calculated = false

# Signals
signal destroyed

# Misc
var health = Settings.enemy_health
var path
var pertti
var path_update_timer
var path_length_to_pertti = 0 #set to 0 to force path calculation at start and because it crashes otherwise
var blood
var thread

func _ready():
	# Visual pathfinding
	#get_parent().add_child(line)
	thread = Thread.new()
	connect("destroyed", get_parent(), "_on_Enemy_destroyed")
	get_parent().connect("free_time", self, "_on_free_time")
	# Do not process right away as that would cause problems, randomize to unsync the calculation, and hopefully unstrain the cpu
	set_process(false)
	set_physics_process(false)
	#path_update_timer = Settings.max_first_path_delay Legacy code

func _process(delta):
	# Look at pertti, looks  t h i c c
	# I see what you did arte, this incident will be reported
	# You just can't handle the truth, he do be dummy thicc
	# I wonder when valzu is gonna make the god damn wall textures
	# Probably when gentoo is done compiling on the uberpotato (aka not before the end of the year)
	# I doubt it is ever going to finish
	if pertti_in_sight:
		look_at(pertti.position)
	
func _physics_process(delta):
	# update_path_timer()
	move_or_slide()

func move_or_slide():
	if !pertti_in_sight and health != 0 and path_calculated:
		move_along_path(Settings.enemy_speed * 0.02)
	# Switch to close proximity follow for better close quarters following
	elif health != 0:
		var direction = (pertti.position - position).normalized()
		move_and_slide(direction * Settings.enemy_speed)

# Legacy code, no longer in use. Kept if needed in the future
func update_path_timer():
	# Operate path update timer
	if path_update_timer <= 0 and !pertti_in_sight and health > 0:
		if can_update and position.distance_to(pertti.position) >= 1000:
			path_calculated = false
			thread.start(self, "update_path", "dummy")
			thread.wait_to_finish()
			path_calculated = true
		path_update_timer = Settings.update_delay_factor * path_length_to_pertti
	else:
		path_update_timer -= 1

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
			look_at(path[0])
			position = start_point.linear_interpolate(path[0], distance / distance_to_next)
			break
		elif distance <= 0.0:
			position = path[0]
			break
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)
		if path.size() == 0:
			calculate_path()

func set_pertti_ref(value):
	# Check if nothing was passed
	if value == null:
		print("no data provided")
		queue_free()
	# Debug messages
	#print(value)
	#print(position)
	pertti = value
	pertti.connect("gameover", self, "_on_Pertti_gameover")
	# Connect a signal to notify enemy to update path
	calculate_path()
	# Check if pathfinding was unsuccessful
	if path.size() == 0:
		return
	# Start _process function and start moving on the path
	set_process(true)
	set_physics_process(true)

func pertti_moved_listener():
	can_update = true

func update_path(dummy):
	# Check if the can update timer has expired, as if this didnt exist the performance would be horrible all time pertto moves
	#if can_update:
	# Restart the timer
	#print("Path updating")
	# Recalculate the path
	path = nav_2d.get_simple_path(position, pertti.position)
	#line.clear_points()
	#for i in path:
	#	line.add_point(i)
	
	#recalculate the length of the route to pertti
	path_length_to_pertti = 0
	var last = pertti.position
	for i in range(1, path.size()):
		path_length_to_pertti += last.distance_to(path[i])
	if path_length_to_pertti * Settings.update_delay_factor <= Settings.minimum_path_delay:
		path_length_to_pertti =  Settings.minimum_path_delay / Settings.update_delay_factor

func calculate_path():
	path_calculated = false
	thread.start(self, "update_path", "dummy")
	thread.wait_to_finish()
	path_calculated = true

func _on_Pertti_gameover():
	print("pertti died")
	queue_free()

func _on_free_time():
	queue_free()

func _kil():
	health = 0
	destroyed = true
	set_process(false)
	emit_signal("destroyed", false)
	get_node("CollisionShape2D").disabled = true
	yield(get_tree().create_timer(1.5), "timeout")
	queue_free()

func _hurt(damage):
	if !destroyed:
		if health > 0:
			blood = blood_scene.instance()
			blood.position = position
			blood.emitting = true
			get_parent().add_child(blood)
			hurt_sound.play()
		if health > 0:
			sprite.frame = 1
			yield(get_tree().create_timer(0.1), "timeout")
			sprite.frame = 0
			health -= damage
		if health <= 0:
			_kil()

func _on_Area2D_body_entered(body):
	# Check if a bullet has entered area, if so reduce health
	if "Bullet" in body.name:
		_hurt(Settings.bullet_damage)

func _on_Collision_area_entered(area):
	if "ExplosionRadius" in area.name:
		_hurt(10)

func _exit_tree():
	thread.wait_to_finish()
	#line.queue_free()

func _on_PerttiDetector_body_entered(body):
	if "Pertti" in body.name:
		pertti_in_sight = true

func _on_PerttiDetector_body_exited(body):
	if "Pertti" in body.name:
		pertti_in_sight = false
		calculate_path()

func _on_PerttiDetector2_body_entered(body):
	print("pertti detected 2")
	calculate_path()

func _on_PerttiDetector3_body_entered(body):
	print("pertti detected 3")
	calculate_path()
