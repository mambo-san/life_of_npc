extends Node2D


#This script/node is responsible for story progression.
#E.g. Listen to events from variaous acitivity, enable various nodes
var player_reached_wall = false
var player_ate_first_item = false
var shroom_1
var shroom_2
var first_item_dialog: Area2D
var second_item_dialog_2: Area2D
var home_dialog: Area2D
var second_shrm_pos = Vector2(220,-40)

func _ready():
	first_item_dialog = $Speech_triggers/first_item_dialog_trigger
	second_item_dialog_2 = $Speech_triggers/second_item_dialog_trigger
	home_dialog = $Speech_triggers/home_dialog_trigger
	#stage setup
	first_item_dialog.monitoring = false
	second_item_dialog_2.monitoring = false
	#Set shroom property and connect to stage 1 specific magical function
	shroom_1 = $Items/Shroom_1
	shroom_1.respawn_rate = 20
	shroom_1.delayed_onset = 12
	shroom_1.player_ate_something.connect(player_picked_up_item)
	shroom_1.visible = false #Hiding but can still collide
	shroom_2 = $Items/Shroom_2
	shroom_2.respawn_rate = 10
	shroom_2.visible = false #Hiding but can still collide
	shroom_2.player_ate_something.connect(player_picked_up_item)
	#Make the player 
	Global.player.get_node("PickUpRange").monitoring = true #TODO set thsi to false for PROD
	Global.player.effect_over.connect(_player_effect_over)
	Global.play_music("BGM")

func _on_reached_wall_dialog_trigger_body_entered(_body):
	if not player_reached_wall:
		player_reached_wall = true
		#Enable/Disable some dialogs
		first_item_dialog.set_deferred("monitoring",true)
		home_dialog.set_deferred("monitoring", false)
		#Add shroom in front of the house and on top
		call_deferred("place_shrooms")
		#Player can now interact with items
		Global.player.get_node("PickUpRange").monitoring = true

func place_shrooms():
	shroom_1.visible = true
	shroom_2.visible = true
	
func player_picked_up_item(_item, _delay_onset):
	
	if not player_ate_first_item:
		Global.debug("Set player_ate_first_item to true")
		player_ate_first_item = true
		shroom_1.respawn_rate = 10
		shroom_1.delayed_onset = 1
		first_item_dialog.monitoring= false
		#Display NPC comment on the effect
		for i in range(3):
			await get_tree().create_timer(4).timeout
			$HUD_canvas.enable_dialog_with_index("first_item_effect", i)
		#Hack to play music as shroom effects kick in
		get_tree().create_timer(3).timeout.connect(first_shroom_dialog)
	#Handle music
	Global.play_music("Chill_music")
	#Set on screen dubug mode on
	Global.set_debug_mode(true)

func first_shroom_dialog():
	Global.set_debug_mode(true)
	$HUD_canvas.enable_dialog_with_index("first_item_effect",3)
	await get_tree().create_timer(5).timeout
	$HUD_canvas.disable_dialog()
	await get_tree().create_timer(2).timeout
	second_item_dialog_2.monitoring = true

func _on_stage_exit_area_body_entered(_body):
	###Implement game ending
	pass # Replace with function body.

func _player_effect_over():
	if $walls/SuicidePreventionWall/CollisionShape2D.disabled:
		Global.play_music("BGM")
		Global.set_debug_mode(false)
