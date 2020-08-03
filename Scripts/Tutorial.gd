extends Node2D

var pertti_scene = preload("res://Scenes/Pertti.tscn")
var enemy_scene = preload("res://Scenes/Enemy.tscn")
var npc_scene = preload("res://Scenes/Npc.tscn")
var tower_enemy_scene = preload("res://Scenes/Tower_Enemy.tscn")
var linus_scene = preload("res://Scenes/Linus.tscn")

onready var health_label = $HUD/HUD/HealthBar/Label
onready var health_bar = $HUD/HUD/HealthBar
onready var score_label = $HUD/HUD/Score
onready var coin_label = $HUD/HUD/Coins
onready var round_indicator_label = $HUD/HUD/RoundTimerIndicator
onready var round_label = $HUD/HUD/RoundLabel
onready var tower_health_bar = $HUD/HUD/ProgressBar
onready var shop_panel = $HUD/Shop/Panel
onready var skip_free_time_button = $HUD/HUD/SkipFreeTime

onready var game_over_label = $HUD/GameOverMenu/GameOverLabel
onready var quit_button = $HUD/GameOverMenu/QuitButton
onready var main_menu_button = $HUD/GameOverMenu/MainMenuButton
onready var restart_button = $HUD/GameOverMenu/RestartButton

onready var respawn_label = $HUD/HUD/RespawnLabel
onready var under_attack_label = $HUD/HUD/UnderAttackLabel
onready var tween : Tween = $HUD/HUD/Tween
onready var shop_ui = $HUD/Shop

var tutorial = true

var pertti

func _ready():
	get_viewport().connect("size_changed", self, "set_positions")
	set_visibility()
	set_positions()
	
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
	$HUD/ColorRect.rect_size = Vector2(get_viewport().size.x, get_viewport().size.y)

func set_visibility():
	skip_free_time_button.visible = false
	shop_panel.visible = false
	game_over_label.visible = false
	quit_button.visible = false
	main_menu_button.visible = false
	restart_button.visible = false
	respawn_label.visible = false
	under_attack_label.visible = false
	
func _on_Shop_body_entered(body):
	if "Pertti" in body.name:
		shop_ui.run_button_checks()
		tween.interpolate_property($HUD/Shop/Panel, "rect_position:x", get_viewport().size.x, get_viewport().size.x - shop_panel.get_rect().size.x, 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
		tween.start()
		shop_panel.visible = true

func _on_Area2D_body_exited(body):
	if "Pertti" in body.name:
		tween.interpolate_property($HUD/Shop/Panel, "rect_position:x", shop_panel.rect_position.x, get_viewport().size.x, 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
		tween.start()
		yield(get_tree().create_timer(0.5), "timeout")
		shop_panel.visible = false

func _on_ExitArea_body_entered(body):
	if "Pertti" in body.name:
		GameManager.exit_to_main_menu()
