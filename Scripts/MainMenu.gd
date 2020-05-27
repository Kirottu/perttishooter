extends Control

onready var bloom = $ColorRect

func _ready():
	bloom.set_size(Vector2(get_viewport().size.x, get_viewport().size.y))
	get_viewport().connect("size_changed", self, "_on_viewport_size_changed")
	
func _on_viewport_size_changed():
	bloom.set_size(Vector2(get_viewport().size.x, get_viewport().size.y))


func _on_PlayButton_pressed():
	get_tree().change_scene("res://Scenes/Level.tscn")


func _on_QuitButton_pressed():
	get_tree().quit()
