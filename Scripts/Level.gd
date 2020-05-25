extends Node2D

func _ready():
	$HUD/ColorRect.set_size(Vector2(get_viewport().size.x, get_viewport().size.y))
	get_viewport().connect("size_changed", self, "_on_viewport_size_changed")

func _on_viewport_size_changed():
	$HUD/ColorRect.set_size(Vector2(get_viewport().size.x, get_viewport().size.y))
