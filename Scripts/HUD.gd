extends Node

onready var health_label = $HealthBar/Label
onready var health_bar = $HealthBar
onready var score_label = $Score
onready var coin_label = $Coins
onready var round_indicator_label = $RoundTimerIndicator
onready var round_label = $RoundLabel
onready var tower_health_bar = $ProgressBar
onready var skip_free_time_button = $SkipFreeTime
onready var respawn_label = $RespawnLabel
onready var under_attack_label = $UnderAttackLabel
onready var tween : Tween = $Tween
onready var level = get_parent().get_parent()

func _ready():
	get_viewport().connect("size_changed", self, "_on_Viewport_size_changed")

func _increase_score(score):
	score_label.text = "Score:" + str(score)

func _change_health(health):
	tween.interpolate_property(health_bar, "value", health_bar.value, health, 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	
	var health_bar_stylebox = health_bar.get("custom_styles/fg")
	health_bar_stylebox.bg_color = Color(1, 1, 1)
		
	yield(get_tree().create_timer(0.2), "timeout")
		
	health_bar_stylebox = health_bar.get("custom_styles/fg")
	health_bar_stylebox.bg_color = Color8(120, 179, 146)

func _change_core_health(health):
	tween.interpolate_property(tower_health_bar, "value", tower_health_bar.value, health, 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	
	var tower_health_bar_stylebox = tower_health_bar.get("custom_styles/fg")
	tower_health_bar_stylebox.bg_color = Color(1, 1, 1)
	yield(get_tree().create_timer(0.2), "timeout")
	
	tower_health_bar_stylebox = tower_health_bar.get("custom_styles/fg")
	tower_health_bar_stylebox.bg_color = Color8(191, 38, 81)

func _change_round(rounds):
	round_label.text = "Round:" + str(rounds)

func _on_Viewport_size_changed():
	respawn_label.rect_position = Vector2((get_viewport().size.x - respawn_label.get_rect().size.x) / 2, (get_viewport().size.y - respawn_label.get_rect().size.y) / 2)
	under_attack_label.rect_position = Vector2((get_viewport().size.x - under_attack_label.get_rect().size.x) / 2, get_viewport().size.y - 100)
	round_indicator_label.rect_position = Vector2((get_viewport().size.x - round_indicator_label.get_rect().size.x) / 2, 50)

func _toggle_under_attack_label(state : bool):
	under_attack_label.visible = state

func _on_SkipFreeTime_pressed():
	level._on_SkipFreeTime_pressed()
