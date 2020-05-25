extends Node2D

onready var pertti : KinematicBody2D = $Pertti
onready var spawn_points = [$SpawnPoints/SpawnPoint1, $SpawnPoints/SpawnPoint2, $SpawnPoints/SpawnPoint3, $SpawnPoints/SpawnPoint4, $SpawnPoints/SpawnPoint5, $SpawnPoints/SpawnPoint6, $SpawnPoints/SpawnPoint7, $SpawnPoints/SpawnPoint8]
onready var nav_2d = $Navigation2D

var enemy_scene = preload("res://Scenes/Enemy.tscn")
var path
var move_timer = 1

func _ready():
	$HUD/ColorRect.set_size(Vector2(get_viewport().size.x, get_viewport().size.y))
	get_viewport().connect("size_changed", self, "_on_viewport_size_changed")

func _physics_process(delta):
	if Settings.spawn_timer > 0:
		Settings.spawn_timer -= 1
	if Settings.spawn_timer == 0:
		Settings.spawn_timer = 300
		_spawn_enemy(0)
		_spawn_enemy(1)
		_spawn_enemy(2)
		_spawn_enemy(3)
		_spawn_enemy(4)
		_spawn_enemy(5)
		_spawn_enemy(6)
		_spawn_enemy(7)
	if move_timer > 0:
		move_timer -= 1
	

func _on_viewport_size_changed():
	$HUD/ColorRect.set_size(Vector2(get_viewport().size.x, get_viewport().size.y))

func _spawn_enemy(spawn_point):
	var enemy = enemy_scene.instance()
	var sel_spawn_point = spawn_points[spawn_point]
	enemy.position = sel_spawn_point.position
	add_child(enemy)
	enemy_loop(enemy)
	
func enemy_loop(enemy):
	print(path)
	print("move func called")
	
	while true:
		path = nav_2d.get_simple_path(enemy.position, pertti.position)
		if path.size() == 0:
			break
		move_along_path(Settings.enemy_speed, enemy)
		while move_timer > 0:
			pass
		
	print("loop broken")
	
func move_along_path(distance : float, enemy):
	var start_point = enemy.position
	for i in range(path.size()):
		var distance_to_next = start_point.distance_to(path[0])
		if distance <= distance_to_next and distance > 0.0:
			enemy.position = start_point.linear_interpolate(path[0], distance / distance_to_next)
			break
		elif distance < 0.0:
			enemy.position = path[0]
			set_process(false)
			break
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)
	
