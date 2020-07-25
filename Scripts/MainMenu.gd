extends Control

func _ready():
	$AudioStreamPlayer.volume_db = Settings.volume
	$MusicLabel/HSlider.value = Settings.volume

func _on_PlayButton_pressed():
	$Click.play()
	get_tree().change_scene("res://Scenes/Level.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()
	$Click.play()

func _on_HSlider_value_changed(value):
	Settings.volume = value
	$AudioStreamPlayer.volume_db = value

func _on_ToolButton_toggled(button_pressed):
	Settings.glow = !button_pressed
	if button_pressed:
		$GlowButton/ToolButton.text = "Disabled"
	else:
		$GlowButton/ToolButton.text = "Enabled"
