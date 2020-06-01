extends Node

# Global variables
# Pertti related variables
var pertti_speed = 500
var bullet_speed = 1000
var fire_rate = 0.4
var pertti_health = 3
var invinsibility = 1.5
var respawn_delay = 3

# Enemy related variables
var enemy_speed = 450
var enemy_health = 2
var tower_enemy_speed = 200
var tower_enemy_health = 5
var path_update_timer = 0.5
var update_delay_factor = 0.05 #factor which the length of the route to pertti from enemy is multiplied with to calculate the amount of physicis frames before next recalculation
var close_proximity_follow_distance = 300
var tower_enemy_probability = 25 # in %

# Level control logic related variables
var warning_flash_interval = 0.08
var round_time = 10
var round_interval = 30
var difficulty_increase = 0.08
var max_first_path_delay = 30 #confusing name, this is the amount of physics steps (max 60/second) before a new path is calculated for the enemies
var minimum_path_delay = 60 #minimum amount of phyisics frames before the path is update, if in really close proximity
var base_difficulty = 2
var tower_health = 50
var tower_damage_interval = 0.5
var attack_initalization_period = 2

#npc related settings
var npc_health = 3
var npc_speed = 100
var closest_to_target = 10 # the npc won't come closer to pertti than this
var npc_active = false

# Variables that change during gameplay, e.g. score, difficulty...
var rounds = 1 # Supposed to be round, but it is a built in type in godot and so unusable
var difficulty = 0
var score = 0
var coins = 0
var nav_2d
