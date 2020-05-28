extends Node

# Global variables
var pertti_speed = 500
var bullet_speed = 1000
var fire_rate = 0.4
var spawn_timer = 180
var enemy_speed = 450
var enemy_health = 4
var tower_enemy_speed = 500
var tower_enemy_health = 3
var pertti_health = 3
var gameover = false
var path_update_timer = 0.5
var invinsibility = 1.5
var update_delay_factor = 0.05 #factor which the length of the route to pertti from enemy is multiplied with to calculate the amount of physicis frames before next recalculation
var respawn_delay = 3
var warning_flash_interval = 0.08

var tower_health = 50
var tower_damage_interval = 30
var attack_initalization_period = 1
#confusing name, this is the amount of physics steps (max 60/second) before a new path is calculated for the enemies
var max_first_path_delay = 30

#minimum amount of phyisics frames before the path is update, if in really close proximity
var minimum_path_delay = 60

# in %
var tower_enemy_probability = 40

var score = 0
