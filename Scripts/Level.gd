extends Node2D

onready var pertti : KinematicBody2D = $Pertti
onready var spawn_points = [$SpawnPoints/SpawnPoint1, $SpawnPoints/SpawnPoint2, $SpawnPoints/SpawnPoint3, $SpawnPoints/SpawnPoint4, $SpawnPoints/SpawnPoint5, $SpawnPoints/SpawnPoint6, $SpawnPoints/SpawnPoint7, $SpawnPoints/SpawnPoint8]

var enemy_scene = preload("res://Scenes/Enemy.tscn")

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

func _on_viewport_size_changed():
	$HUD/ColorRect.set_size(Vector2(get_viewport().size.x, get_viewport().size.y))

func _spawn_enemy(spawn_point):
	var enemy = enemy_scene.instance()
	var sel_spawn_point = spawn_points[spawn_point]
	enemy.position = sel_spawn_point.position
	add_child(enemy)
	
	enemy.pertti_pos = pertti.position
	 
