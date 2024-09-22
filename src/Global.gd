extends Node

signal player_ready

var debug_scene: PackedScene = preload("res://Scene/debug_message.tscn")
var sound_manager
var player: CharacterBody2D
var HUD_canvas #Broker for HUD related things including speech bubble
var _on_screen_debug_mode = false
# Called when the node enters the scene tree for the first time.
func _ready():
	var debug_collection = Node.new()
	debug_collection.name = "debug_collection"
	add_child(debug_collection)
	debug("Global script ready")
	

func set_player(player_node):
	player = player_node
	player_ready.emit()

func play_music(sound_name: String):
	sound_manager.changeMusic(sound_name)
	Global.debug("Switching music: " + sound_name)

func play_sound(sound_name: String):
	sound_manager.playSound(sound_name)
	Global.debug("Playing sound: " + sound_name)

func debug(message:String):
	if _on_screen_debug_mode:
		var debug_message = debug_scene.instantiate().with_message(message)
		#Determine where to position the debug
		var camera = player.get_node("Camera") as Camera2D
		var view_port_size = get_viewport().get_visible_rect().size / camera.zoom 
		var center_pos = camera.get_screen_center_position()
		#X offset is easy, add half the screen width
		var offset_x = view_port_size.x / 2
		var pos_x = center_pos.x + offset_x
		#Y offset needs random value 
		var offset_y = randi_range(-view_port_size.y / 2, view_port_size.y / 2)
		var pos_y = center_pos.y + offset_y
		debug_message.position = Vector2(pos_x, pos_y)
		debug_message.z_index = 1
		
		$debug_collection.call_deferred("add_child",debug_message)
	if OS.has_feature("standalone"): #running as exported build
		pass
	else:#We are in editor, print to consoled
		print(message)

func set_debug_mode(debug_mode: bool) -> void:
	_on_screen_debug_mode = debug_mode
	if debug_mode == false:
		#Kill all debug instances
		for node in $debug_collection.get_children():
			print(node.get_class())
			node.queue_free()
