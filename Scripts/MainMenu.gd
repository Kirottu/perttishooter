extends Control

var environment

func _ready():
	SaveControl._load()
	Settings.glow = SaveControl.save_data["glow"]
	Settings.crt = SaveControl.save_data["crt"]
	$GlowButton/ToolButton.pressed = !Settings.glow
	$CrtButton/ToolButton.pressed = !Settings.crt
	get_viewport().connect("size_changed", self, "_on_Viewport_size_changed")
	print(SaveControl.save_data)
	$Highscore.text = "High score: " + str(SaveControl.save_data["score"]) + ", round " + str(SaveControl.save_data["round"])
	$AudioStreamPlayer.volume_db = Settings.volume
	$MusicLabel/HSlider.value = Settings.volume

func _on_Viewport_size_changed():
	set_positions()

func set_positions():
	$ColorRect.rect_size = Vector2(get_viewport().size.x, get_viewport().size.y)

func _physics_process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

func _on_PlayButton_pressed():
	$Click.play()
	GameManager.infinite()

func _on_QuitButton_pressed():
	get_tree().quit()
	$Click.play()

func _on_HSlider_value_changed(value):
	Settings.volume = value
	$AudioStreamPlayer.volume_db = value

func _on_ToolButton_toggled(button_pressed):
	Settings.glow = !button_pressed
	environment = $WorldEnvironment.environment
	environment.glow_enabled = Settings.glow
	$WorldEnvironment.environment = environment
	if button_pressed:
		$GlowButton/ToolButton.text = "Disabled"
	else:
		$GlowButton/ToolButton.text = "Enabled"
	SaveControl.save_settings(Settings.glow, Settings.crt)

func _on_CrtButton_toggled(button_pressed):
	Settings.crt = !button_pressed
	$ColorRect.visible = Settings.crt
	if button_pressed:
		$CrtButton/ToolButton.text = "Disabled"
	else:
		$CrtButton/ToolButton.text = "Enabled"
	SaveControl.save_settings(Settings.glow, Settings.crt)
