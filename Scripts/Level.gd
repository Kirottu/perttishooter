extends Node2D

# Node refrences
onready var pertti : KinematicBody2D = $Pertti
onready var spawn_points = [$SpawnPoints/SpawnPoint1, $SpawnPoints/SpawnPoint2, $SpawnPoints/SpawnPoint3, $SpawnPoints/SpawnPoint4, $SpawnPoints/SpawnPoint5, $SpawnPoints/SpawnPoint6, $SpawnPoints/SpawnPoint7, $SpawnPoints/SpawnPoint8]
onready var health_label = $HUD/Label

# Other variables
var gameover = false
var rng = RandomNumberGenerator.new()
var enemy_scene = preload("res://Scenes/Enemy.tscn")
var path
var spawn_timer = Settings.spawn_timer

func _ready():
	# Set bloom overlay size correctly and connect a signal when the scene is ready
	$HUD/ColorRect.set_size(Vector2(get_viewport().size.x, get_viewport().size.y))
	get_viewport().connect("size_changed", self, "_on_viewport_size_changed")
	health_label.text = "Health:" + str(Settings.pertti_health)

func _physics_process(delta):
	if !gameover:
		# Operate the timer between spawns
		if spawn_timer > 0:
			spawn_timer -= 1
		if spawn_timer == 0:
			rng.randomize()
			# Set a random time for when the next enemy spawns
			spawn_timer = rng.randi_range(60, 180)
			rng.randomize()
			# Spawn an enemy to a random spawnpoint
			_spawn_enemy(rng.randi_range(0,7))
	

func _on_viewport_size_changed():
	# Set the bloom overlay size correctly when viewport size changes
	$HUD/ColorRect.set_size(Vector2(get_viewport().size.x, get_viewport().size.y))

func _spawn_enemy(spawn_point):
	# Instance the enemy from preloaded scene
	var enemy = enemy_scene.instance()
	# Set sel_spawn_point variable to the spawn point chosen
	var sel_spawn_point = spawn_points[spawn_point]
	# Set enemies position based on sel_spawn_point
	enemy.position = sel_spawn_point.position
	add_child(enemy)
	# Pass reference to pertti to the enemy
	enemy.set_pertti_ref(pertti)


func _on_Pertti_damage_taken(health):
	health_label.text = "Health:" + str(health)


func _on_Pertti_gameover():
	gameover = true
