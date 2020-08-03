extends Node

var infinite_map_scene = preload("res://Scenes/Levels/LevelInfinite.tscn")

var level setget load_infinite

func _ready():
	pass

func infinite():
	get_tree().change_scene("res://Scenes/Level.tscn")
	
func load_infinite(level):
	var infinite_map = infinite_map_scene.instance()
	level.load_map(infinite_map, false)

func restart_game():
	get_tree().change_scene(get_tree().current_scene.get_path())

func exit_to_main_menu():
	get_tree().change_scene("res://Scenes/MainMenu.tscn")

func tutorial():
	get_tree().change_scene("res://Scenes/Levels/Tutorial.tscn")
