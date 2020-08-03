extends KinematicBody2D

# Scenes
var mine = preload("res://Scenes/Mine.tscn")
var blood_scene = preload("res://Scenes/Blood.tscn")

# Node references
onready var nav_2d = $Navigation2D
onready var hurt_sound = $Hurt
onready var explosion = $Explosion
onready var sprite = $Sprite
onready var tilemap = $Navigation2D/TileMap
onready var tween = $Tween

# As you obviously can tell yourself, this loads the mine scene. But comments everywhere except here is ugly :helpmeplz:
var mine_scene = preload("res://Scenes/Mine.tscn")

# Bools
var can_update = false
var destroyed = false
var path_calculated = false
export var tutorial = false

# Signals
signal destroyed

# Misc
var rng = RandomNumberGenerator.new()
var destination
var path
var lastpos
var tiles = []
var tiles_map = []
var health = Settings.mine_enemy_health
var timer = Timer.new()
var thread
var blood

func _ready():
	thread = Thread.new()
	if !tutorial:
		get_parent().connect("free_time", self, "_on_free_time")
		tiles_map = tilemap.get_used_cells()
		for i in tiles_map.size():
			var tile = tilemap.map_to_world(tiles_map[i])
			tiles.append(tile)
		rng.randomize()
		yield(get_tree().create_timer(0.1), "timeout")
		update_path()
	else:
		set_physics_process(false)
		set_process(false)

func _physics_process(delta):
	if !destroyed and path_calculated:
		move_along_path(Settings.mine_enemy_speed * delta)

func _place_mine():
	var mine = mine_scene.instance()
	mine.position = position
	# call parent, cause the mines need to stay when Linus've been thinking of retiring.
	get_parent().add_child(mine)

func _on_free_time():
	queue_free()

func update_path():
	path_calculated = false
	thread.start(self, "calculate_path", "dummy")
	thread.wait_to_finish()
	path_calculated = true
	rotation = lerp_angle(rotation, position.angle_to_point(path[0]), 0.25)
	
func calculate_path(dummy):
	rng.randomize()
	destination = tiles[rng.randi_range(0, tiles_map.size() - 1)]
	path = nav_2d.get_simple_path(position, destination)

func move_along_path(distance):
	
	var start_point = position
	for i in range(path.size()):
		var distance_to_next = start_point.distance_to(path[0])
		if distance <= distance_to_next and distance > 0.0:
			rotation = lerp_angle(rotation, position.angle_to_point(path[0]), 0.25)
			position = start_point.linear_interpolate(path[0], distance / distance_to_next)
			break
		elif distance <= 0.0:
			position = path[0]
			break
		path.remove(0)
		if path.size() == 0:
			update_path()
			
func _kil():
	health = 0
	destroyed = true
	set_process(false)
	emit_signal("destroyed", true)
	get_node("CollisionPolygon2D").disabled = true
	yield(get_tree().create_timer(1.5), "timeout")
	queue_free()

func _hurt(damage):
	if !destroyed:
		if health > 0:
			blood = blood_scene.instance()
			blood.position = position
			blood.emitting = true
			get_parent().add_child(blood)
			hurt_sound.play()
		if health > 0:
			sprite.frame = 1
			yield(get_tree().create_timer(0.1), "timeout")
			sprite.frame = 0
			health -= damage
		if health <= 0:
			_kil()

func _on_Area2D_body_entered(body):
	if "Bullet" in body.name:
		_hurt(1)

func _exit_tree():
	thread.wait_to_finish()

func _on_Area2D_area_entered(area):
	if "ExplosionRadius" in area.name:
		_hurt(10)
