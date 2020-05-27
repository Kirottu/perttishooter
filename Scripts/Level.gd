extends Node2D

# Node refrences
onready var pertti : KinematicBody2D = $Pertti
onready var spawn_points = [$SpawnPoints/SpawnPoint1, $SpawnPoints/SpawnPoint2, $SpawnPoints/SpawnPoint3, $SpawnPoints/SpawnPoint4, $SpawnPoints/SpawnPoint5, $SpawnPoints/SpawnPoint6, $SpawnPoints/SpawnPoint7, $SpawnPoints/SpawnPoint8]
onready var health_label = $HUD/Label
onready var score_label = $HUD/Score

onready var game_over_label = $HUD/GameOverMenu/GameOverLabel
onready var quit_button = $HUD/GameOverMenu/QuitButton
onready var main_menu_button = $HUD/GameOverMenu/MainMenuButton
onready var restart_button = $HUD/GameOverMenu/RestartButton

# Other variables
var gameover = false
var rng = RandomNumberGenerator.new()
var enemy_scene = preload("res://Scenes/Enemy.tscn")
var path
var spawn_timer = Settings.spawn_timer
var score_timer

func _ready():
	game_over_label.visible = false
	quit_button.visible = false
	main_menu_button.visible = false
	restart_button.visible = false
	
	set_positions()
	
	# Set bloom overlay size correctly and connect a signal when the scene is ready
	get_viewport().connect("size_changed", self, "_on_viewport_size_changed")
	health_label.text = "Health:" + str(Settings.pertti_health)
	
	Settings.score = 0
	score_timer = Timer.new()
	add_child(score_timer)
	score_timer.connect("timeout", self, "_increase_score")
	score_timer.set_wait_time(1.0)
	score_timer.set_one_shot(false) # Make sure it loops
	score_timer.start()

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
	set_positions()

func set_positions():
	$HUD/ColorRect.set_size(Vector2(get_viewport().size.x, get_viewport().size.y))
	game_over_label.rect_position = Vector2((get_viewport().size.x - game_over_label.get_rect().size.x) / 2, get_viewport().size.y / 4)
	quit_button.rect_position = Vector2((get_viewport().size.x - quit_button.get_rect().size.x) / 2, get_viewport().size.y / 4 + 250)
	main_menu_button.rect_position = Vector2((get_viewport().size.x - main_menu_button.get_rect().size.x) / 2, get_viewport().size.y / 4 + 175)
	restart_button.rect_position = Vector2((get_viewport().size.x - restart_button.get_rect().size.x) / 2, get_viewport().size.y / 4 + 100)

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
	game_over_label.visible = true
	quit_button.visible = true
	main_menu_button.visible = true
	restart_button.visible = true
	yield(get_tree().create_timer(1.5), "timeout")
	get_tree().paused = true
	
func _increase_score():
	if !gameover:
		Settings.score += 1
		score_label.text = "Score:" + String(Settings.score)


func _on_MainMenuButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/MainMenu.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_RestartButton_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
