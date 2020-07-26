extends Node

# Global variables
var bullet_damage = 1
var mine_damage = 2
var bullet_speed = 1000

# Pertti related variables
var pertti_speed = 500
var fire_rate = 0.4
var pertti_health = 3
var invinsibility = 1.5
var respawn_delay = 3

# Enemy related variables
var enemy_speed = 450
var enemy_health = 2
var tower_enemy_speed = 200
var tower_enemy_health = 5
var update_delay_factor = 0.1 #factor which the length of the route to pertti from enemy is multiplied with to calculate the amount of physicis frames before next recalculation
var close_proximity_follow_distance = 500
var tower_enemy_spawn_interval = 10
var core_enemy_explosion_time = 5

# Level control logic related variables
var warning_flash_interval = 0.08
var round_time = 60
var difficulty_increase = 0.1
var max_first_path_delay = 120 #confusing name, this is the amount of physics steps (max 60/second) before a new path is calculated for the enemies
var minimum_path_delay = 120 #minimum amount of phyisics frames before the path is update, if in really close proximity
var base_difficulty = 3
var tower_health = 50
var tower_damage_interval = 0.5
var attack_initalization_period = 2
var explosion_damage = 10

# Npc related settings
var npc_fire_rate = 0.4
var npc_health = 3
var npc_speed = 300
var closest_to_target = 10 # the npc won't come closer to pertti than this
var npc_active = false

# Mine enemy related settings
var mine_enemy_speed = 400
var mine_enemy_health = 3
var mine_place_interval = 10

# Variables that change during gameplay, e.g. score, difficulty...
var rounds = 1 # Supposed to be round, but it is a built in type in godot and so unusable
var difficulty = 0
var score = 0
var coins = 0

# Actual settings
var volume = -5
var glow = true
