extends Node2D

# Node refrences
# HUD References
onready var health_label = $HUD/HUD/HealthBar/Label
onready var health_bar = $HUD/HUD/HealthBar
onready var score_label = $HUD/HUD/Score
onready var coin_label = $HUD/HUD/Coins
onready var round_indicator_label = $HUD/HUD/RoundTimerIndicator
onready var round_label = $HUD/HUD/RoundLabel
onready var tower_health_bar = $HUD/HUD/ProgressBar
onready var shop_panel = $HUD/Shop/Panel
onready var skip_free_time_button = $HUD/HUD/SkipFreeTime

# Gameover menu references
onready var game_over_label = $HUD/GameOverMenu/GameOverLabel
onready var quit_button = $HUD/GameOverMenu/QuitButton
onready var main_menu_button = $HUD/GameOverMenu/MainMenuButton
onready var restart_button = $HUD/GameOverMenu/RestartButton

# Misc references
onready var shop = $Shop
onready var tower = $Tower
onready var respawn_label = $HUD/HUD/RespawnLabel
onready var under_attack_label = $HUD/HUD/UnderAttackLabel
onready var tween : Tween = $HUD/HUD/Tween
onready var shop_ui = $HUD/Shop

# Scenes
var pertti_scene = preload("res://Scenes/Pertti.tscn")
var enemy_scene = preload("res://Scenes/Enemy.tscn")
var npc_scene = preload("res://Scenes/Npc.tscn")
var tower_enemy_scene = preload("res://Scenes/Tower_Enemy.tscn")
var linus_scene = preload("res://Scenes/Linus.tscn")

# Bools
var gameover = false
var tower_destroyed = false
var enemies_spawnable = true
var round_interval = false

# Integers/floats
var tower_health = Settings.tower_health
var enemies_in_tower = 0
var round_indicator_thingy = Settings.round_time

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
var tower_enemy_spawn_timer
var environment

func _ready():
	set_visibility()
	set_default_values()
	_spawn_pertti()
	set_positions()
	create_timers()
	round_timer_indicator()
	get_viewport().connect("size_changed", self, "_on_viewport_size_changed")

func spawn_enemies():
	if !gameover and !round_interval:
		
		rng.randomize()
		
		_spawn_enemy(rng.randi_range(0,7))

func spawn_tower_enemies():
	rng.randomize()
	_spawn_tower_enemy(rng.randi_range(0,7))
	
	yield(get_tree().create_timer(0.1), "timeout")
	
	rng.randomize()
	_spawn_linus(rng.randi_range(0,7))

func set_visibility():
	skip_free_time_button.visible = false
	shop_panel.visible = false
	game_over_label.visible = false
	quit_button.visible = false
	main_menu_button.visible = false
	restart_button.visible = false
	respawn_label.visible = false
	under_attack_label.visible = false

func set_default_values():
	environment = $WorldEnvironment.environment
	environment.glow_enabled = Settings.glow
	$WorldEnvironment.environment = environment
	score_label.text = "Score:" + str(Settings.score)
	coin_label.text = "Coins:" + str(Settings.coins)
	round_label.text = "Round:" + str(Settings.rounds)
	tower_health_bar.value = Settings.tower_health
	$AudioStreamPlayer.volume_db = Settings.volume
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

	tower_enemy_spawn_timer = Timer.new()
	add_child(tower_enemy_spawn_timer)
	tower_enemy_spawn_timer.connect("timeout", self, "spawn_tower_enemies")
	tower_enemy_spawn_timer.set_wait_time(Settings.tower_enemy_spawn_interval)
	tower_enemy_spawn_timer.set_one_shot(false)
	tower_enemy_spawn_timer.start()

func set_positions():
	shop_panel.rect_size = Vector2(710, get_viewport().size.y - 200)
	shop_panel.rect_position = Vector2(get_viewport().size.x, 100)
	game_over_label.rect_position = Vector2((get_viewport().size.x - game_over_label.get_rect().size.x) / 2, get_viewport().size.y / 4)
	shop_panel.get_node("ScrollContainer").rect_size = Vector2(shop_panel.rect_size.x, shop_panel.rect_size.y - 60)
	shop_panel.get_node("ScrollContainer").rect_position = Vector2(0, 60)
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
	yield(get_tree().create_timer(0.1), "timeout")
	enemy.set_pertti_ref(pertti)

func _spawn_tower_enemy(spawn_point):
	# Instance the enemy from preloaded scene
	var enemy = tower_enemy_scene.instance()
	# Set sel_spawn_point variable to the spawn point chosen
	var sel_spawn_point = spawn_points[spawn_point]
	# Set enemies position based on sel_spawn_point
	enemy.position = sel_spawn_point.position
	add_child(enemy)

func _spawn_npc():
	var npc = npc_scene.instance()
	npc.position = shop.position
	add_child(npc)

func _spawn_linus(point):
	var linus = linus_scene.instance()
	linus.position = spawn_points[point].position
	add_child(linus)

func _on_Pertti_damage_taken(health):
	$HUD/HUD._change_health(health)

func _round_timer_elapsed():
	round_interval = true
	emit_signal("free_time")
	if Settings.base_difficulty > 0.1:
		Settings.base_difficulty -= Settings.difficulty_increase
		spawn_timer.set_wait_time(Settings.base_difficulty)
	round_indicator_label.text = "Free time"
	skip_free_time_button.visible = true
	round_timer.stop()
	score_timer.stop()
	tower_enemy_spawn_timer.stop()
	if !tower_destroyed:
		under_attack_label.visible = false

func _increase_score():
	round_timer_indicator()
	if !gameover:
		Settings.score += 1
		$HUD/HUD._increase_score(Settings.score)

func round_timer_indicator():
	if !round_interval:
		round_indicator_label.text = "Time left:" + str(round_indicator_thingy)
		round_indicator_thingy -= 1

func slide_color(color : Color, light_node : Light2D, amplitude : float, tored : bool, notower : bool):
	if tored and !notower:
		while light_node.color != color and enemies_in_tower != 0:
			light_node.color = light_node.color.linear_interpolate(color, amplitude)
			yield(get_tree().create_timer(0.1), "timeout")
	elif !notower:
		while light_node.color != color and enemies_in_tower == 0:
			light_node.color = light_node.color.linear_interpolate(color, amplitude)
			yield(get_tree().create_timer(0.1), "timeout")
	else:
		while light_node.color != color:
			light_node.color = light_node.color.linear_interpolate(color, amplitude)
			yield(get_tree().create_timer(0.1), "timeout")

func initialization_period():
	under_attack_label.text = "Initializing attack..."
	slide_color(Color8(191, 38, 81), $Tower/Light2D, 0.1, true, false)
	while enemies_in_tower > 0:
		under_attack_label.set("custom_colors/font_color", Color8(191, 38, 81))
		yield(get_tree().create_timer(Settings.warning_flash_interval), "timeout")
		under_attack_label.set("custom_colors/font_color", Color8(255, 255, 255))
		yield(get_tree().create_timer(Settings.warning_flash_interval), "timeout")

func _on_Area2D_body_entered(body):
	if "Tower" in body.name and !tower_destroyed:
		enemies_in_tower += 1
		under_attack_label.visible = true
		initialization_period()
		
func _on_Tower_Enemy_exited():
	enemies_in_tower -= 1
	if enemies_in_tower <= 0 and !tower_destroyed:
		under_attack_label.visible = false
		slide_color(Color(1, 1, 1), $Tower/Light2D, 0.1, false, false)

func _on_Enemy_destroyed(tower_enemy : bool):
	if !tower_enemy:
		Settings.coins += 1 * Settings.coin_multiplier
	elif tower_enemy:
		Settings.coins += 2 * Settings.coin_multiplier
	coin_label.text = "Coins:" + str(Settings.coins)

func _on_Shop_body_entered(body):
	if "Pertti" in body.name:
		shop_ui.run_button_checks()
		tween.interpolate_property($HUD/Shop/Panel, "rect_position:x", get_viewport().size.x, get_viewport().size.x - shop_panel.get_rect().size.x, 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
		tween.start()
		shop_panel.visible = true

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
	spawn_timer.start()
	$HUD/HUD._change_health(Settings.pertti_health)

func _on_Pertti_gameover():
	if !tower_destroyed:
		spawn_timer.stop()
		respawn_label.visible = true
		for i in range(Settings.respawn_delay):
			respawn_label.text = "Respawning In:" + str(Settings.respawn_delay - i)
			yield(get_tree().create_timer(1), "timeout")

	elif tower_destroyed:
		gameover = true
		game_over_label.visible = true
		quit_button.visible = true
		main_menu_button.visible = true
		restart_button.visible = true
		SaveControl.save(Settings.score, Settings.rounds)
		yield(get_tree().create_timer(1.5), "timeout")
		get_tree().paused = true

func _on_viewport_size_changed():
	set_positions()

func _on_Area2D_body_exited(body):
	if "Pertti" in body.name:
		tween.interpolate_property($HUD/Shop/Panel, "rect_position:x", shop_panel.rect_position.x, get_viewport().size.x, 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
		tween.start()
		yield(get_tree().create_timer(0.5), "timeout")
		shop_panel.visible = false

func _on_SkipFreeTime_pressed():
	round_timer.start()
	score_timer.start(0.99)
	if !tower_destroyed:
		tower_enemy_spawn_timer.start()
	round_indicator_thingy = Settings.round_time
	round_indicator_label.text = "Round starting"
	Settings.rounds += 1
	$HUD/HUD._change_round(Settings.rounds)
	Settings.difficulty += Settings.difficulty_increase
	round_interval = false
	skip_free_time_button.visible = false

func _on_Core_enemy_explosion():
	tower_health -= Settings.explosion_damage
	$HUD/HUD._change_core_health(tower_health)
	if tower_health <= 0:
		tower_destroyed = true
		under_attack_label.text = "Core destroyed"
		under_attack_label.visible = true
		emit_signal("core_destroyed")
		tower_enemy_spawn_timer.stop()


