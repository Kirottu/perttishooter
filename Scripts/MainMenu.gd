extends Control

func _on_PlayButton_pressed():
	$AudioStreamPlayer.play()
	Network.create_server("Harold")
	get_tree().change_scene("res://Scenes/Level.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()
	$AudioStreamPlayer.play()

func _on_Volume_toggled(button_pressed):
	if button_pressed:
		Settings.music = false
		$AudioStreamPlayer2.stop()
	elif !button_pressed:
		Settings.music = true
		$AudioStreamPlayer2.play()

func _on_PlayButton2_pressed():
	$AudioStreamPlayer.play()
	Network.connect_to_server("Linus")
	get_tree().change_scene("res://Scenes/Level.tscn")
