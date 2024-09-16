extends StaticBody2D

func _ready():
	pass
	#set visible false
	
func _process(_delta):
	if Global.player.ate_shroom:
		visible = true
	else:
		visible = false
	var new_x = 11 - Global.player.position.x #TODO This 11 is the Cucumber's initial pos
	var new_y = Global.player.position.y
	position = Vector2(new_x, new_y)
