extends KinematicBody2D

# Scenes
var mine = preload("res://Scenes/Mine.tscn")

# Node references
onready var nav_2d = $Navigation2D
onready var hurt_sound = $Hurt
onready var explosion = $Explosion
onready var sprite = $Sprite
onready var tilemap = $Navigation2D/TileMap

# As you obviously can tell yourself, this loads the mine scene. But comments everywhere except here is ugly :helpmeplz:
var mine_scene = preload("res://Scenes/Mine.tscn")

# Bools
var can_update = false
var destroyed = false

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

func _ready():
	get_parent().connect("free_time", self, "_on_free_time")
	connect("placemine", get_parent(), "_spawn_mine")
	tiles_map = tilemap.get_used_cells()
	for i in tiles_map.size():
		var tile = tilemap.map_to_world(tiles_map[i])
		tiles.append(tile)
	
	rng.randomize()
	update_path_if_needed(true)
	
	add_child(timer)
	timer.connect("timeout", self, "_place_mine")
	timer.set_wait_time(Settings.mine_place_interval)
	timer.set_one_shot(false)
	timer.start()

func _physics_process(delta):
	update_path_if_needed(false)
	lastpos = position
	if !destroyed:
		move_along_path(Settings.mine_enemy_speed * delta)

func _place_mine():
	var mine = mine_scene.instance()
	mine.position = position
	# call parent, cause the mines need to stay when Linus've been thinking of retiring.
	get_parent().add_child(mine)

func _on_free_time():
	queue_free()

func update_path_if_needed(force):
	if force or lastpos == position or position.distance_to(destination) < Settings.closest_to_target:
		rng.randomize()
		destination = tiles[rng.randi_range(0, tiles_map.size() - 1)]
		path = nav_2d.get_simple_path(position, destination)

func move_along_path(distance):
	var start_point = position
	for i in range(path.size()):
		var distance_to_next = start_point.distance_to(path[0])
		if distance <= distance_to_next and distance > 0.0:
			look_at(path[0])
			position = start_point.linear_interpolate(path[0], distance / distance_to_next)
			break
		elif distance <= 0.0:
			position = path[0]
			break
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)

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
