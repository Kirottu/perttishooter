extends Node2D

# Node refrences
# HUD References
onready var health_label = $HUD/HUD/Label
onready var score_label = $HUD/HUD/Score
onready var coin_label = $HUD/HUD/Coins
onready var round_indicator_label = $HUD/HUD/RoundTimerIndicator
onready var round_label = $HUD/HUD/RoundLabel
onready var tower_health_bar = $HUD/HUD/ProgressBar

# Gameover menu references
onready var game_over_label = $HUD/GameOverMenu/GameOverLabel
onready var quit_button = $HUD/GameOverMenu/QuitButton
onready var main_menu_button = $HUD/GameOverMenu/MainMenuButton
onready var restart_button = $HUD/GameOverMenu/RestartButton

# Misc references
onready var tower = $Tower
onready var respawn_label = $HUD/HUD/RespawnLabel
onready var under_attack_label = $HUD/HUD/UnderAttackLabel

# Scenes
var pertti_scene = preload("res://Scenes/Pertti.tscn")
var enemy_scene = preload("res://Scenes/Enemy.tscn")
var tower_enemy_scene = preload("res://Scenes/Tower_Enemy.tscn")

# Bools
var gameover = false
var tower_destroyed = false
var tower_under_attack = false
var enemies_spawnable = true
var round_interval = false
var core_damageable = true

# Integers/floats
var tower_health = Settings.tower_health
var enemies_in_tower = 0
var tower_damage_interval = Settings.tower_damage_interval

# Signals
signal core_destroyed
signal free_time

# Misc
var rng = RandomNumberGenerator.new()
var path
var score_timer
var pertti
var health_bar_stylebox
var round_timer
var spawn_points = []
var spawn_timer
var core_damage_timer

func _ready():
	set_visibility()
	set_default_values()
	_spawn_pertti()
	set_positions()
	create_timers()
	round_timer_indicator()
	get_viewport().connect("size_changed", self, "_on_viewport_size_changed")

func core_damage():
	if !tower_destroyed and tower_under_attack and tower_health != 0 and core_damageable:
		core_damageable = false
		yield(get_tree().create_timer(Settings.tower_damage_interval), "timeout")
		core_damageable = true
		tower_health -= 1
		tower_health_bar.value = tower_health
		
	elif tower_health == 0:
		tower_destroyed = true
		core_damage_timer.stop()
		under_attack_label.text = "Core destroyed!"
		under_attack_label.visible = true
		emit_signal("core_destroyed")

func spawn_enemies():
	if !gameover and enemies_spawnable and !round_interval:
		rng.randomize()
		# Spawn an enemy to a random spawnpoint
		if rng.randi_range(0,100) > Settings.tower_enemy_probability:
			_spawn_enemy(rng.randi_range(0,7))
		elif !tower_destroyed:
			_spawn_tower_enemy(rng.randi_range(0,7))
		else:
			_spawn_enemy(rng.randi_range(0,7))

func set_visibility():
	game_over_label.visible = false
	quit_button.visible = false
	main_menu_button.visible = false
	restart_button.visible = false
	respawn_label.visible = false
	under_attack_label.visible = false

func set_default_values():
	health_label.text = "Health:" + str(Settings.pertti_health)
	score_label.text = "Score:" + str(Settings.score)
	coin_label.text = "Coins:" + str(Settings.coins)
	round_label.text = "Round:" + str(Settings.rounds)
	tower_health_bar.value = Settings.tower_health
	for i in $SpawnPoints.get_children():
		spawn_points.append(i)

func create_timers():
	round_timer = Timer.new()
	add_child(round_timer)
	round_timer.connect("timeout", self, "_round_timer_elapsed")
	round_timer.set_wait_time(Settings.round_time)
	round_timer.set_one_shot(false)
	round_timer.start()
	
	score_timer = Timer.new()
	add_child(score_timer)
	score_timer.connect("timeout", self, "_increase_score")
	score_timer.set_wait_time(1.0)
	score_timer.set_one_shot(false) # Make sure it loops
	score_timer.start()
	
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.connect("timeout", self, "spawn_enemies")
	spawn_timer.set_wait_time(Settings.base_difficulty)
	spawn_timer.set_one_shot(false)
	spawn_timer.start()
	
	core_damage_timer = Timer.new()
	add_child(core_damage_timer)
	core_damage_timer.connect("timeout", self, "core_damage")
	core_damage_timer.set_wait_time(Settings.tower_damage_interval)
	core_damage_timer.set_one_shot(false)

func set_positions():
	$HUD/ColorRect.set_size(Vector2(get_viewport().size.x, get_viewport().size.y))
	game_over_label.rect_position = Vector2((get_viewport().size.x - game_over_label.get_rect().size.x) / 2, get_viewport().size.y / 4)
	quit_button.rect_position = Vector2((get_viewport().size.x - quit_button.get_rect().size.x) / 2, get_viewport().size.y / 4 + 250)
	main_menu_button.rect_position = Vector2((get_viewport().size.x - main_menu_button.get_rect().size.x) / 2, get_viewport().size.y / 4 + 175)
	restart_button.rect_position = Vector2((get_viewport().size.x - restart_button.get_rect().size.x) / 2, get_viewport().size.y / 4 + 100)
	respawn_label.rect_position = Vector2((get_viewport().size.x - respawn_label.get_rect().size.x) / 2, (get_viewport().size.y - respawn_label.get_rect().size.y) / 2)
	under_attack_label.rect_position = Vector2((get_viewport().size.x - under_attack_label.get_rect().size.x) / 2, get_viewport().size.y - 100)
	round_indicator_label.rect_position = Vector2((get_viewport().size.x - round_indicator_label.get_rect().size.x) / 2, 50)
	
func _spawn_pertti():
	pertti = pertti_scene.instance()
	pertti.position = tower.position
	add_child(pertti)

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

func _spawn_tower_enemy(spawn_point):
	# Instance the enemy from preloaded scene
	var enemy = tower_enemy_scene.instance()
	# Set sel_spawn_point variable to the spawn point chosen
	var sel_spawn_point = spawn_points[spawn_point]
	# Set enemies position based on sel_spawn_point
	enemy.position = sel_spawn_point.position
	add_child(enemy)

func _on_Pertti_damage_taken(health):
	health_label.text = "Health:" + str(health)

func _round_timer_elapsed():
	round_interval = true
	print("Round interval")
	emit_signal("free_time")
	tower_under_attack = false
	core_damage_timer.stop()
	under_attack_label.visible = false
	yield(get_tree().create_timer(Settings.round_interval), "timeout")
	print("Round interval elapsed")
	Settings.rounds += 1
	round_label.text = "Round:" + str(Settings.rounds)
	Settings.difficulty += Settings.difficulty_increase
	round_interval = false

func _increase_score():
	if !gameover:
		Settings.score += 1
		score_label.text = "Score:" + String(Settings.score)

func warning_flash():
	while tower_under_attack:
		var health_bar_stylebox = tower_health_bar.get("custom_styles/fg")
		health_bar_stylebox.bg_color = Color(1,1,1)
		
		yield(get_tree().create_timer(Settings.warning_flash_interval), "timeout")
		
		health_bar_stylebox = tower_health_bar.get("custom_styles/fg")
		health_bar_stylebox.bg_color = Color(1,0,0)
		
		yield(get_tree().create_timer(Settings.warning_flash_interval), "timeout")

func round_timer_indicator():
	# TODO fix this shit, pause menu will crash the game or still update the
	# Round time indicator while paused
	for i in range(Settings.round_time):
		while get_tree().paused:
			pass
		round_indicator_label.text = "Round left:" + str(Settings.round_time - i)
		yield(get_tree().create_timer(1), "timeout")
	for i in range(Settings.round_interval):
		while get_tree().paused:
			pass
		round_indicator_label.text = "Free time:" + str(Settings.round_interval - i)
		yield(get_tree().create_timer(1), "timeout")

func initialization_period():
	under_attack_label.text = "Initializing attack..."
	while !tower_under_attack:
		under_attack_label.set("custom_colors/font_color", Color(1, 0, 0, 1))
		yield(get_tree().create_timer(Settings.warning_flash_interval), "timeout")
		under_attack_label.set("custom_colors/font_color", Color(1, 1, 1, 1))
		yield(get_tree().create_timer(Settings.warning_flash_interval), "timeout")
		if enemies_in_tower == 0:
			break

func _on_Area2D_body_entered(body):
	if "Tower" in body.name and !tower_destroyed:
		enemies_in_tower += 1
		under_attack_label.visible = true
		if !tower_under_attack:
			initialization_period()
			yield(get_tree().create_timer(Settings.attack_initalization_period), "timeout")
		if enemies_in_tower != 0:
			tower_under_attack = true
			core_damage_timer.start()
			under_attack_label.text = "Core under attack!"
			warning_flash()

func _on_Tower_Enemy_exited():
	print("Enemy exited")
	enemies_in_tower -= 1
	if enemies_in_tower == 0:
		tower_under_attack = false
		under_attack_label.visible = false
		core_damage_timer.stop()

func _on_Enemy_destroyed(tower_enemy : bool):
	if !tower_enemy:
		Settings.coins += 1
	elif tower_enemy:
		Settings.coins += 2
	coin_label.text = "Coins:" + str(Settings.coins)

func _on_Shop_body_entered(body):
	if body.name == "Pertti":
		print("Shop entered")

func _on_MainMenuButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/MainMenu.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_RestartButton_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_Pertti_respawn():
	_spawn_pertti()
	respawn_label.visible = false
	enemies_spawnable = true

func _on_Pertti_gameover():
	if !tower_destroyed:
		enemies_spawnable = false
		respawn_label.visible = true
		for i in range(Settings.respawn_delay):
			respawn_label.text = "Respawning In:" + str(Settings.respawn_delay-i)
			yield(get_tree().create_timer(1), "timeout")

		
		#pertti.animation.play("Invinsibility")
	elif tower_destroyed:
		gameover = true
		game_over_label.visible = true
		quit_button.visible = true
		main_menu_button.visible = true
		restart_button.visible = true
		yield(get_tree().create_timer(1.5), "timeout")
		get_tree().paused = true

func _on_viewport_size_changed():
	set_positions()
