extends RigidBody2D

var player
signal player_ate_something
var rng

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var picked_up = false
#Animation interpolation
var move_progress = 0
var source_y = 0
var target_y = 0
var spew_direction_x = 70
var respawn_rate = 0 #seconds after it's picked up
var delayed_onset = 1

func _ready():
	if not Global.player:
		await Global.player_ready
	player = Global.player
	player_ate_something.connect(player.player_ate_something.bind())
	rng = RandomNumberGenerator.new()
	

func _physics_process(delta):
	if picked_up:
		
		#interpolation = A + (B - A) * t
		#A = position.y
		#B = target_y
		move_progress += delta * 4
		position.y = source_y - (source_y - target_y) * move_progress
		if move_progress >= 1:
			picked_up = false
			move_progress = 0
			await get_tree().create_timer(0.4).timeout
			if respawn_rate > 0:
				get_tree().create_timer(respawn_rate).timeout.connect(set_deferred.bind("visible", true))
				gravity_scale = 1
				visible = false
			else:
				visible = false
				await get_tree().create_timer(delayed_onset).timeout
				queue_free()


func picked_up_by_player():
	print(str(self) + "Geting picked up by Player")
	gravity_scale = 0
	source_y = position.y
	target_y = position.y - 10
	await get_tree().create_timer(0.5).timeout
	picked_up = true
	#Wake up surrounding items physics so gravity is applied
	var surrounding_items = $Area2D.get_overlapping_areas()
	for other_item in surrounding_items:
		other_item.get_parent().set_sleeping(false)

	#call the child method which can be overriden 
	_item_effect()
	
func _item_effect():
	emit_signal("player_ate_something", self, delayed_onset) #Default 


func spew_animation(direction):
	#Set mask layer off and apply impulse
	set_collision_layer_value(2, false)
	set_collision_mask_value(2, false)
	set_collision_mask_value(3, false)
	apply_impulse(Vector2(spew_direction_x * direction, rng.randi_range(-100,0)))
	var timer = get_tree().create_timer(3) #Destoy the vomit after awhile 
	timer.timeout.connect(queue_free.bind())
