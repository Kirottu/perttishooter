extends KinematicBody2D

# Scenes
var bullet = preload("res://Scenes/NpcBullet.tscn")

# Node references
onready var nav_2d = $Navigation2D
onready var hurt_sound = $Hurt
onready var explosion = $Explosion
onready var sprite = $Sprite
onready var tilemap = $Navigation2D/TileMap
onready var tween = $Tween

# Bools
var can_update = false
var enemy_in_sight = false
var destroyed = false
var can_fire = true
var path_calculated = false

# Signals
signal destroyed

# Misc
var rng = RandomNumberGenerator.new()
var destination
var path
var lastpos
var current_target
var tiles = []
var tiles_map = []
var thread

func _ready():
	thread = Thread.new()
	tiles_map = tilemap.get_used_cells()
	for i in tiles_map.size():
		var tile = tilemap.map_to_world(tiles_map[i])
		tiles.append(tile)
	
	rng.randomize()
	update_path()

func _physics_process(delta):
	if enemy_in_sight:
		rotation = position.angle_to_point(current_target.position)
		_fire()
	if path_calculated:
		move_along_path(delta * Settings.npc_speed)
	
func update_path():
		# Pass a dummy argument, wont work otherwise
		# TODO this is dumb
	path_calculated = false
	thread.start(self, "calculate_path", "boi")
	thread.wait_to_finish()
	path_calculated = true
	rotation = lerp_angle(rotation, position.angle_to_point(path[0]), 0.25)
	
func calculate_path(dummy):
	rng.randomize()
	destination = tiles[rng.randi_range(0, tiles_map.size() - 1)]
	path = nav_2d.get_simple_path(position, destination)

func _fire():
	if can_fire:
		$Fireball.play()
		$BulletPoint/Particles2D.emitting = true
		var new_bullet = bullet.instance()
		new_bullet.position = $BulletPoint.get_global_position()
		new_bullet.rotation_degrees = rotation_degrees 
		new_bullet.apply_impulse(Vector2(), Vector2(-Settings.bullet_speed, 0).rotated(rotation))
		get_tree().get_root().add_child(new_bullet)
		can_fire = false
		yield(get_tree().create_timer(Settings.npc_fire_rate), "timeout")
		can_fire = true

func move_along_path(distance):
	var start_point = position
	for i in range(path.size()):
		var distance_to_next = start_point.distance_to(path[0])
		if distance <= distance_to_next and distance > 0.0:
			if !enemy_in_sight:
				rotation = lerp_angle(rotation, position.angle_to_point(path[0]), 0.25)
			position = start_point.linear_interpolate(path[0], distance / distance_to_next)
			break
		elif distance <= 0.0:
			position = path[0]
			break
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)
		if path.size() == 0:
			update_path()
			
func _on_Area2D_body_entered(body):
	print(body.name)
	if "Enemy" in body.name:
		current_target = body
		body.connect("destroyed", self, "_on_selected_enemy_destroyed")
		enemy_in_sight = true

func _on_Area2D_body_exited(body):
	if body == current_target:
		enemy_in_sight = false
		current_target = null
	
func _on_selected_enemy_destroyed(enemy_type):
	enemy_in_sight = false
	current_target = null

func _exit_tree():
	thread.wait_to_finish()
