extends Node2D

const level_path = "res://Scene/levels/level_"
const unknown_level = "res://Scene/levels/level_404.tscn"

var current_lvl := 0
var current_scene : Node
# Called when the node enters the scene tree for the first time.
func _ready():
	load_next_level()


func load_next_level():
	Global.player = null
	current_lvl += 1
	var next_scene = _get_level(current_lvl).instantiate()
	add_child(next_scene)
	if current_scene:
		current_scene.queue_free()
	current_scene = next_scene


func _get_level(level: int) -> PackedScene:
	var level_tscn_name = level_path + str(level) + ".tscn"
	if ResourceLoader.exists(level_tscn_name):
		return load(level_tscn_name)
	return load(unknown_level)


func is_f6() -> bool:
	var play_ground = get_node_or_null("/root/PlayGround")
	if play_ground:
		return false
	return true
