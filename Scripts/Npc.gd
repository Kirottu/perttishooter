extends KinematicBody2D

# Scenes
var bullet = preload("res://Scenes/Bullet.tscn")

# Node references
onready var nav_2d = $Navigation2D
onready var hurt_sound = $Hurt
onready var explosion = $Explosion
onready var sprite = $Sprite
onready var tilemap = $Navigation2D/TileMap

# Bools
var can_update = false
var enemy_in_sight = false
var destroyed = false

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

func _ready():
	tiles_map = tilemap.get_used_cells()
	for i in tiles_map.size():
		var tile = tilemap.map_to_world(tiles_map[i])
		tiles.append(tile)
	
	rng.randomize()
	connect("body_entered", self, "_on_seeing_something")
	update_path_if_needed(true)

func _physics_process(delta):
	update_path_if_needed(false)
	lastpos = position

	move_along_path(delta * Settings.npc_speed)
func update_path_if_needed(force):
	if force or lastpos == position or position.distance_to(destination) < Settings.closest_to_target:
		rng.randomize()
		destination = tiles[rng.randi_range(0, tiles_map.size() - 1)]
		path = nav_2d.get_simple_path(position, destination)

func _on_seeing_something():
	print("saw one")

func move_along_path(distance):
	var start_point = position
	for i in range(path.size()):
		var distance_to_next = start_point.distance_to(path[0])
		if distance <= distance_to_next and distance > 0.0:
			position = start_point.linear_interpolate(path[0], distance / distance_to_next)
			break
		elif distance <= 0.0:
			position = path[0]
			break
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)
		

func _on_Area2D_body_entered(body):
	print("saw smth")
	if "Enemy" in body.name and !destroyed:
		current_target = body
		print("saw em")
