extends KinematicBody2D

# Node references
onready var nav_2d = $Navigation2D
onready var hurt_sound = $Hurt
onready var explosion = $Explosion
onready var sprite = $Sprite

# Bools
var can_update = false
var enemy_in_sight = false
var destroyed = false

# Signals
signal destroyed

# Misc
var rng = RandomNumberGenerator.new()
var health = Settings.npc_health
var path
var pertti
var path_update_timer
var path_length_to_pertti = 0 #set to 0 to force path calculation at start and because it crashes otherwise

func _ready():
	connect("destroyed", get_parent(), "_on_Enemy_destroyed")
	get_parent().connect("free_time", self, "_on_free_time")
	# Do not process right away as that would cause problems, randomize to unsync the calculation, and hopefully unstrain the cpu
	set_process(false)
	rng.randomize()
	path_update_timer = rng.randf_range(0, Settings.max_first_path_delay)

func _process(delta):
	look_at(pertti.position)
	
func _physics_process(delta):
	set_enemy_reference()
	move_to_enemy()
	
func set_enemy_reference():
	print("todo lol")
	#if position.distance_to(pertti.position) <= Settings.close_proximity_follow_distance:

func move_to_enemy():
	if health != 0:
		var start_point = position
		var direction = ( pertti.position - self.position).normalized()
		move_and_slide(direction * 500)

func _on_Pertti_gameover():
	print("F")

func _on_Area2D_body_entered(body):
	# Check if a bullet has entered area, if so reduce health
	if "Bullet" in body.name and !destroyed:
		if health > 1:
			hurt_sound.play()
		if health > 0:
			sprite.frame = 1
			yield(get_tree().create_timer(0.1), "timeout")
			sprite.frame = 0
			health -= 1
		if health == 0:
			destroyed = true
			explosion.play()
			set_process(false)
			emit_signal("destroyed", false)
			get_node("CollisionShape2D").queue_free()
			yield(get_tree().create_timer(1.5), "timeout")
			# Queue for deletion in the next frame when health == 0
			queue_free()
