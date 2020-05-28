extends KinematicBody2D

onready var nav_2d = $Navigation2D
onready var hurt_sound = $Hurt
onready var explosion = $Explosion
onready var tower = get_tree().get_root().get_node("Level/Tower")

var health = Settings.tower_enemy_health
var path
var pertti
var destroyed = false

signal exited

func _ready():
	path = nav_2d.get_simple_path(position, tower.position)
	connect("exited", get_parent(), "_on_Tower_Enemy_exited")
	get_parent().connect("core_destroyed", self, "_on_Level_core_destroyed")

func _process(delta):
	look_at(tower.position)

func _physics_process(delta):
	if health > 0 and position.distance_to(tower.position) > 70:
		move_along_path(Settings.tower_enemy_speed * 0.02)
		# TODO: add case for when it's arrived, to optimize and stuff

func _on_Level_core_destroyed():
	queue_free()

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
			if position.distance_to(tower.position) < 90:
				emit_signal("exited")
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

