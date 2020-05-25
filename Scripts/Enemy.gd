extends KinematicBody2D

"""onready var nav_2d = get_node("Navigation2D")
onready var line_2d = get_node("Line2D")

var path
var pertti_pos = Vector2() setget set_pertti_pos

func _ready():
	set_process(false)

func _process(delta):
	var move_distance = Settings.enemy_speed * delta
	move_along_path(move_distance)"""
	

func _on_Area2D_body_entered(body):
	
	if "Bullet" in body.name:
		queue_free()

"""func move_along_path(distance : float):
	var start_point = position
	for i in range(path.size()):
		var distance_to_next = start_point.distance_to(path[0])
		if distance <= distance_to_next and distance > 0.0:
			position = start_point.linear_interpolate(path[0], distance / distance_to_next)
			break
		elif distance < 0.0:
			position = path[0]
			set_process(false)
			break
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)
	

func set_pertti_pos(value) -> void:
	if value == Vector2():
		print("no data provided")
		return
	print(value)
	print(position)
	pertti_pos = value
	path = nav_2d.get_simple_path(position, pertti_pos)
	print(path)
	if path.size() == 0:
		return
	set_process(true)
	print("processing")"""

	
	
