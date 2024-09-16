extends ColorRect

var player
# Variables for references
@export var marker_morning: Marker2D
@export var marker_noon: Marker2D
@export var marker_night: Marker2D
@export var marker_sky: Marker2D
@export var marker_ground: Marker2D

# Color variables
var start_color := Color(0.918, 0.875, 0.671)  # #78b6ff
var noon_color := Color(0.421, 0.725, 1) # Example noon color (light yellowish)
var night_color := Color(0.05, 0.05, 0.3)  # Example night color (dark blueish)

#Toggle color direction
var reached_noon := false
var reached_night := false

# Internal variable to keep track of progress
var transition_progress := 0.0

func _ready():
	if not Global.player:
		await Global.player_ready
	player = Global.player
	for star in $Stars.get_children():
		star.modulate.a = 0

func _process(delta):
	if not reached_noon or not reached_night:
		update_day_night_color()
	else:
		update_star_alpha()
		rotate_star(delta)

func update_day_night_color():
	# Get player's x position
	var player_x = player.global_position.x
	# Get x positions of the markers
	var marker_morning_x = marker_morning.global_position.x
	var marker_noon_x = marker_noon.global_position.x
	var marker_night_x = marker_night.global_position.x
	# Determine the transition progress towards the noon marker
	if not reached_noon:
		var progress = clamp((player_x - marker_morning_x) / (marker_noon_x - marker_morning_x), 0.0, 1.0)
		transition_progress = max(transition_progress, progress)  # Ensure no backward transition
		color = start_color.lerp(noon_color, transition_progress)
		if transition_progress >= 1:
			reached_noon = true
			transition_progress = 0
	# Transition from noon to night after the player passes the noon marker
	elif not reached_night and player_x < marker_noon_x:
		var progress = clamp((marker_noon_x - player_x) / (marker_noon_x - marker_night_x), 0.0, 1.0)
		transition_progress = max(transition_progress, progress)  # Prevent backward transition
		color = noon_color.lerp(night_color, transition_progress)
		if transition_progress >= 1:
			reached_night = true
			transition_progress = 0

func update_star_alpha():
	var ground_y = marker_ground.global_position.y
	var sky_y = marker_sky.global_position.y
	var player_y = player.global_position.y
	if player_y < ground_y and player_y > sky_y:
		var progress = clamp((ground_y - player_y) / (ground_y - sky_y), 0.0, 1.0)
		for star in $Stars.get_children():
			star.modulate.a = progress

func rotate_star(delta):
	for star in $Stars.get_children() as Array[Sprite2D]:
		star.rotation_degrees -= 30 * delta
	
	
