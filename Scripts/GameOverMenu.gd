extends Node

func _on_MainMenuButton_pressed():
	get_tree().change_scene("res://Scenes/MainMenu.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_RestartButton_pressed():
	get_tree().reload_current_scene()
