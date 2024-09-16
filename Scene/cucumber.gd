extends Node2D

#When player approaches, put the head out from the ground.

const CUCUM_HIGHT = 84 #Not a joke, I swear
const CUCUM_RANGE = 100
const min_distance = -400
var cucum_above_ground_y: float
var cucum_underground_y: float

var player #local copy to measure distance

func _ready():
	await Global.player_ready
	player = Global.player
	cucum_above_ground_y = position.y
	cucum_underground_y = position.y + CUCUM_HIGHT
	position.y = cucum_underground_y # Hide when it's initialized
	
	print(player)
	
	
func _process(_delta):
	if player:
		var player_pos_x = player.position.x
		var distance = abs(position.x - player_pos_x) -40
		if distance < CUCUM_RANGE:
			var lerp_weight = distance/CUCUM_RANGE
			var new_pos_y = lerp(cucum_underground_y, cucum_above_ground_y, 1- lerp_weight)
			new_pos_y = clamp(new_pos_y, cucum_above_ground_y, cucum_underground_y )
			position.y = new_pos_y
