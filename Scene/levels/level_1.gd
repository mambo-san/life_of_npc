extends Node2D

const floor_scene = "res://Scene/levels/floor.tscn"
var floor_res
var player
var floor_created : Array[int]
var tile_size
const floor_base_y := 405.0

#camera stuff
const MAX_zoom = 13.0
const MIN_zoom = 1.0
var current_zoom = MAX_zoom

@export var exit_left :Area2D
@export var exit_right :Area2D

signal ui_accept_pressed
#TODO hack to supress player control for exit scene
var input_left_event = InputMap.action_get_events("walk_left")
var input_right_event = InputMap.action_get_events("walk_right")

func _ready() -> void:
	print("_ready level 1 start")
	set_process(false)
	#Get the player instance and freeze until dialog is complete
	if not Global.player:
		await Global.player_ready
	player = Global.player
	player.set_process(false)
	# Preload moving floor (and add the first one)
	floor_res = preload(floor_scene)
	var x_int = int(player.global_position.x / 10)
	var floor = floor_res.instantiate()
	floor.position = Vector2(x_int * 10,floor_base_y)
	add_child(floor)
	floor_created.append(x_int)
	# Dialog
	await get_tree().create_timer(3).timeout
	set_process(true)
	for i in range(0, 2):
		_show_dialog("time_for_work", i)
		await ui_accept_pressed
	_hide_dialog()
	_toggle_progress_bar(true)
	##End of dialog, enable player movement 
	player.set_process(true)
	
	print("_ready level 1 end")
	

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		ui_accept_pressed.emit()

func _process(delta: float) -> void:
	var player_x = player.global_position.x
	var x_int = int(player_x / 10)
	
	for index in range(max(x_int-5, -100), min(x_int+6, 101)):
		if not floor_created.has(index):
			var floor = floor_res.instantiate()
			floor.position = Vector2(index * 10,floor_base_y)
			add_child(floor)
			floor_created.append(index)
	var progress = abs(player_x / 10)
	$UILayer/ProgressBar.value = progress
	var new_zoom = clamp(lerpf(MAX_zoom, MIN_zoom, progress/90), MIN_zoom, current_zoom)
	current_zoom = new_zoom
	$player/Camera2D.set_zoom(Vector2(new_zoom,new_zoom))

func _show_dialog(dialog_key: String, index: int=-1) -> void:
	var dialog_data = DialogTexts.get_dialog_text(dialog_key, index)
	$UILayer/DialogPanel.set_dialog_animation(dialog_data)
	$UILayer/DialogPanel.visible = true

func _hide_dialog() ->void:
	$UILayer/DialogPanel.visible = false
	
func _toggle_progress_bar(flag: bool) ->void:
	if flag == true: 
		$UILayer/ProgressBar.visible = true
		$UILayer/ProgressBar.modulate.a = 1.0
	else:
		var tween = $UILayer/ProgressBar.create_tween()
		tween.tween_property($UILayer/ProgressBar, "modulate:a", 0.0, 2)

func _on_exit_right_body_entered(body: Node2D) -> void:
	print("Triggered Right exit")
	Input.action_press("walk_right")
	_exit_sequence()

func _on_exit_left_body_entered(body: Node2D) -> void:
	print("Triggered Left exit")
	Input.action_press("walk_left")
	_exit_sequence()

func _exit_sequence():
	_toggle_player_movement(false)
	_toggle_progress_bar(false)
	$UILayer/Animation.play("fade_out")

func _toggle_player_movement(enable:bool):
	if enable:
		for event in input_left_event:
			InputMap.action_add_event("walk_left", event)
		for event in input_right_event:
			InputMap.action_add_event("walk_right", event)
		Input.action_release("walk_left")
		Input.action_release("walk_right")
	else:
		InputMap.action_erase_events("walk_left")
		InputMap.action_erase_events("walk_right")

func _on_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		_toggle_player_movement(true)
		get_tree().root.get_node("/root/Main").load_next_level()
