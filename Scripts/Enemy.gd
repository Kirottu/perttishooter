extends KinematicBody2D

onready var nav_2d = get_node("Navigation2D")
onready var line_2d = get_node("Line2D")

var health = Settings.enemy_health
var path
var pertti
var path_update_timer = 30
var can_update = false

func _ready():
	set_process(false)

func _process(delta):
	look_at(pertti.position)
	
	var move_distance = Settings.enemy_speed * delta
	
	move_along_path(move_distance)
	
func _physics_process(delta):
	if path_update_timer == 0:
		can_update = true
		path_update_timer = 30
	if path_update_timer > 0:
		path_update_timer -= 1


func _on_Area2D_body_entered(body):
	
	if "Bullet" in body.name:
		health -= 1
		if health == 0:
			queue_free()

func move_along_path(distance : float):
	var start_point = position
	
	for i in range(path.size()):
		var distance_to_next = start_point.distance_to(path[0])
		if distance <= distance_to_next and distance > 0.0:
			position = start_point.linear_interpolate(path[0], distance / distance_to_next)
			break
		elif distance <= 0.0:
			position = path[0]
			
			print(is_processing())
			break
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)
		print(pertti.position)
	

func set_pertti_ref(value) -> void:
	if value == null:
		print("no data provided")
		return
	print(value)
	print(position)
	pertti = value
	pertti.connect("moved", self, "update_path")
	path = nav_2d.get_simple_path(position, pertti.position)
	print(path)
	if path.size() == 0:
		return
	set_process(true)
	print("processing")

func update_path():
	if can_update:
		can_update = false
		print("Path updated")
		path = nav_2d.get_simple_path(position, pertti.position)
	
	
