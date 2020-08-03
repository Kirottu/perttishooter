extends Node

onready var level = get_parent().get_parent()
func _ready():
	pass

func run_button_checks():
	for button in $Panel/ScrollContainer/VBoxContainer.get_children():
		if !level.tutorial:
			match button.text:
				"100% Core, 30 Coins":
					if !level.tower_destroyed and level.tower_health < Settings.tower_health and Settings.coins >= 30:
						button.disabled = false
					else:
						button.disabled = true
				"100% Pertti, 15 Coins":
					if level.pertti.health < Settings.pertti_health and Settings.coins >= 15:
						button.disabled = false
					else:
						button.disabled = true
				"2X HP Core, 60 Coins":
					if !level.tower_destroyed and Settings.coins >= 60:
						button.disabled = false
					else:
						button.disabled = true
				"2X HP Pertti, 60 Coins":
					if Settings.coins >= 60:
						button.disabled = false
					else:
						button.disabled = true
				"Harold, 90 Coins":
					if Settings.coins >= 90:
						button.disabled = false
					else:
						button.disabled = true
				"Coin booster, 90 Coins":
					if Settings.coins >= 90:
						button.disabled = false
					else:
						button.disabled = true
		else:
			button.disabled = true
		
func _on_Harold_pressed():
	get_parent().get_parent().get_node("Click").play()
	level._spawn_npc()
	Settings.coins -= 90
	level.coin_label.text = "Coins:" + str(Settings.coins)
	run_button_checks()

func _on_Pertti2X_pressed():
	get_parent().get_parent().get_node("Click").play()
	Settings.coins -= 60
	Settings.pertti_health *= 2
	level.pertti.health = Settings.pertti_health
	level.health_bar.max_value = Settings.pertti_health
	level.tween.interpolate_property(get_parent().get_node("HUD/HealthBar"), "value", get_parent().get_node("HUD/HealthBar").value, level.pertti.health, 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	level.tween.start()
	level.coin_label.text = "Coins:" + str(Settings.coins)
	run_button_checks()

func _on_CoreHealthAdd_pressed():
	get_parent().get_parent().get_node("Click").play()
	level.tower_health = Settings.tower_health
	Settings.coins -= 30
	level.tween.interpolate_property(get_parent().get_node("HUD/ProgressBar"), "value", get_parent().get_node("HUD/ProgressBar").value, level.tower_health, 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	level.tween.start()
	level.coin_label.text = "Coins:" + str(Settings.coins)
	run_button_checks()

func _on_PerttiHealth_pressed():
	get_parent().get_parent().get_node("Click").play()
	Settings.coins -= 15
	level.pertti.health = Settings.pertti_health
	level.tween.interpolate_property(get_parent().get_node("HUD/HealthBar"), "value", get_parent().get_node("HUD/HealthBar").value, level.pertti.health, 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	level.tween.start()
	level.coin_label.text = "Coins:" + str(Settings.coins)
	run_button_checks()

func _on_Core2X_pressed():
	get_parent().get_parent().get_node("Click").play()
	Settings.tower_health *= 2
	level.tower_health_bar.max_value = Settings.tower_health
	level.tower_health = Settings.tower_health
	level.tween.interpolate_property(get_parent().get_node("HUD/ProgressBar"), "value", get_parent().get_node("HUD/ProgressBar").value, level.tower_health, 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	level.tween.start()
	Settings.coins -= 60
	level.coin_label.text = "Coins:" + str(Settings.coins)
	run_button_checks()

func _on_CoinBooster_pressed():
	get_parent().get_parent().get_node("Click").play()
	Settings.coin_multiplier *= 2
	Settings.coins -= 90
	level.coin_label.text = "Coins:" + str(Settings.coins)
	run_button_checks()
