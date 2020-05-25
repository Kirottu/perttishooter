extends Node2D

onready var pertti : KinematicBody2D = $Pertti
onready var spawn_points = [$SpawnPoints/SpawnPoint1, $SpawnPoints/SpawnPoint2, $SpawnPoints/SpawnPoint3, $SpawnPoints/SpawnPoint4, $SpawnPoints/SpawnPoint5, $SpawnPoints/SpawnPoint6, $SpawnPoints/SpawnPoint7, $SpawnPoints/SpawnPoint8]
onready var nav_2d = $Navigation2D

var enemy_scene = preload("res://Scenes/Enemy.tscn")
var path
var spawn_timer = Settings.spawn_timer

func _ready():
	$HUD/ColorRect.set_size(Vector2(get_viewport().size.x, get_viewport().size.y))
	get_viewport().connect("size_changed", self, "_on_viewport_size_changed")

func _physics_process(delta):
	if spawn_timer > 0:
		spawn_timer -= 1
	if spawn_timer == 0:
		spawn_timer = Settings.spawn_timer
		for i in range(8):
			_spawn_enemy(i)

	

func _on_viewport_size_changed():
	$HUD/ColorRect.set_size(Vector2(get_viewport().size.x, get_viewport().size.y))

func _spawn_enemy(spawn_point):
	var enemy = enemy_scene.instance()
	var sel_spawn_point = spawn_points[spawn_point]
	enemy.position = sel_spawn_point.position
	add_child(enemy)
	enemy.pertti_pos = pertti.position
