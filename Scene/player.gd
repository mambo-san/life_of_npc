extends CharacterBody2D

const TURD_SCRIPT = preload("res://Scene/pick_ups/turd.gd")
const SHROOM_SCRIPT = preload("res://Scene/pick_ups/shroom.gd")
const TURD_SCENE = preload("res://Scene/pick_ups/turd.tscn")
const SHROOM_SCENE = preload("res://Scene/pick_ups/shroom.tscn")

const SPEED = 40.0
const FLOAT_WALK_SPEED = 20.0

var eat_count = 0
var stomach = [] #Keep track of what the player ate

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var last_direction = 0 #Keeping track of which way character is facing
#Animation interpolation
var move_progress = 0
var target_x = 0

#Shroom effect
var ate_shroom := false #Duration of shroom effect
var reached_height := false #Duration of initial floating effect
const SHRM_HIGHT = 100
var target_hight
const SHRM_Y_VELOCITY = -15
var shrm_time_passed := 0.0
const SHRM_TOTAL_DURATION := 13.0
const SHRM_FLOAT_DURATION := 8.0 #Duration for the initial move
const SHRM_OSCIL_DURATION := 3.0 #Duration to move up and down
const SHRM_AMPLITUDE := 10 #Max Y displacement by +/- 20

signal effect_over

func _ready():
	Global.set_player(self)
	print("Regisered Player to Global script")
	

func _process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("pick_up"):
		Global.debug("pick_up action pressed")
		if not ate_shroom:
			var things_in_range = $PickUpRange.get_overlapping_bodies()
			if things_in_range.size() > 0:
				print(things_in_range)
				play_pick_up_animation(things_in_range[0])
				eat_count += 1
		else:
			Global.debug("Nothing to pick up")
	
	var direction = 0
	if not $AnimationPlayer.current_animation == "pick_up":
		direction = Input.get_axis("walk_left", "walk_right")
	
	if $AnimationPlayer.current_animation == "pick_up":
		#Ignore user input and adjust the position to the item
		velocity.x = 0 
		move_progress += delta * 0.4
		position.x = position.x + (target_x - position.x) * move_progress
	elif ate_shroom: #Gradually float with while oscillating
		shrm_time_passed += delta
		#Calculate the oscilate offset
		var y_offset = SHRM_AMPLITUDE * sin((shrm_time_passed/SHRM_OSCIL_DURATION)*2*PI)
		if reached_height: 
			velocity.y = SHRM_Y_VELOCITY + y_offset
			if position.y <= target_hight:
				reached_height = false
		elif shrm_time_passed < SHRM_TOTAL_DURATION: #Continue oscilating for awhile
			velocity.y = y_offset
		else:
			ate_shroom = false
			shrm_time_passed = 0.0
			move_progress = 0
			emit_signal("effect_over")
		#Also needs to handle input
		if direction > 0:
			$Sprite2D.flip_h = false
			$AnimationPlayer.play("float_right")
			velocity.x = direction * FLOAT_WALK_SPEED 
			last_direction = direction
		elif direction < 0:
			$Sprite2D.flip_h = true
			$AnimationPlayer.play("float_right")
			velocity.x = direction * FLOAT_WALK_SPEED 
			last_direction = direction
	else:
		if direction > 0:
			$Sprite2D.flip_h = false
			$AnimationPlayer.play("walk_right")
			velocity.x = direction * SPEED 
			last_direction = direction
		elif direction < 0:
			$Sprite2D.flip_h = true
			$AnimationPlayer.play("walk_right")
			velocity.x = direction * SPEED 
			last_direction = direction
		else:
			var new_velocity_x = move_toward(velocity.x, 0, SPEED)
			velocity.x = new_velocity_x
			$AnimationPlayer.play("standing")
	move_and_slide()


func play_pick_up_animation(item):
	if (item.position.x > position.x):
		#move player to the left
		target_x = item.position.x - 9
		last_direction = 1
		$Sprite2D.flip_h = false
	else:
		#move player to the right and flip the sprite
		target_x = item.position.x + 9
		last_direction = -1
		$Sprite2D.flip_h = true
	#Play the animation of the thing being picked up
	$AnimationPlayer.play("pick_up")
	item.picked_up_by_player()
	
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "pick_up":
		move_progress = 0
		target_x = 0

func player_ate_something(item, delay_onset):
	if delay_onset > 0:
		await get_tree().create_timer(delay_onset).timeout
	if item is TURD_SCRIPT:
		Global.debug("Player ate turd")
		stomach.append(TURD_SCENE)
		spew()
	elif item is SHROOM_SCRIPT:
		Global.debug("Player ate shroom")
		stomach.append(SHROOM_SCENE)
		ate_shroom = true
		reached_height = true
		target_hight = position.y - SHRM_HIGHT
		$AnimationPlayer.play("float_right")
	else:
		Global.debug("Player ate something else")

func spew():
	Global.debug("Player Spewing")
	await get_tree().create_timer(1.2).timeout
	Global.debug("Spewing stomach content")
	for index in stomach.size():
		var item_scene = stomach.pop_back()
		var item = item_scene.instantiate()
		Global.debug("Stomach_content[" + str(index) + "]=" + str(item.name))
		item.position.x = position.x + (5*last_direction)
		item.position.y = position.y -3
		item.scale *= 0.1
		get_tree().root.add_child(item)
		item.spew_animation(last_direction)
		await get_tree().create_timer(0.1).timeout
		
	stomach = []
	
