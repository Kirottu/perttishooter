extends KinematicBody2D

# Node reference
onready var nav_2d = $Navigation2D
onready var hurt_sound = $Hurt
onready var explosion = $Explosion
onready var tower = get_tree().get_root().get_node("Level/Tower")
onready var sprite = $Sprite

# Signals
signal exited
signal destroyed
signal explosion

# Bools
var destroyed = false

# Misc
var health = Settings.tower_enemy_health
var path
var pertti

func _ready():
	path = nav_2d.get_simple_path(position, tower.position)
	print(path[0])
	connections()

func _process(delta):
	look_at(tower.position)

func _physics_process(delta):
	if health > 0 and position.distance_to(tower.position) > 70:
		move_along_path(Settings.tower_enemy_speed * 0.02)
		# TODO: add case for when it's arrived, to optimize and stuff
		# Done^^

func connections():
	connect("exited", get_parent(), "_on_Tower_Enemy_exited")
	connect("destroyed", get_parent(), "_on_Enemy_destroyed")
	get_parent().connect("core_destroyed", self, "_on_Level_core_destroyed")
	get_parent().connect("free_time", self, "_on_free_time")
	connect("explosion", get_parent(), "_on_Core_enemy_explosion")

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
		path.remove(0)
		distance -= distance_to_next
		#start_point = path[0]

func _on_Level_core_destroyed():
	emit_signal("exited")
	queue_free()

func _on_free_time():
	queue_free()

func _on_Area2D_body_entered(body):
	# Check if a bullet has entered area, if so reduce health
	if "Bullet" in body.name and !destroyed:
		if health > 1:
			hurt_sound.play()
		if health > 0:
			health -= 1
			sprite.frame = 1
			yield(get_tree().create_timer(0.1), "timeout")
			sprite.frame = 0
		if health == 0:
			destroyed = true
			explosion.play()
			set_process(false)
			emit_signal("destroyed", true)
			if position.distance_to(tower.position) < 90:
				emit_signal("exited")
			get_node("CollisionShape2D").queue_free()
			yield(get_tree().create_timer(1.5), "timeout")
			# Queue for deletion in the next frame when health == 0
			queue_free()

func _on_Collision_area_entered(area):
	if area.name == "Core":
		yield(get_tree().create_timer(Settings.core_enemy_explosion_time), "timeout")
		if !destroyed:
			emit_signal("explosion")
			emit_signal("exited")
			queue_free()
