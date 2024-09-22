extends Node2D

const MAX_Y = -800
var up_speed = 800.0
var down_speed = 50.0
var player_detected = false
var decommissioned = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	down_speed = randf_range(20,40)
	up_speed = randf_range(800,820)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_detected:
		var current_y = $tile.position.y
		var new_y = clamp(current_y-delta * up_speed, MAX_Y, current_y)
		$tile.position.y = new_y
	else:
		var current_y = $tile.position.y
		var new_y = clamp(current_y+delta * down_speed, current_y, 0)
		$tile.position.y = new_y

func decommission():
	decommissioned = true 
	
func _on_detection_area_body_entered(body: Node2D) -> void:
	player_detected = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	player_detected = false
