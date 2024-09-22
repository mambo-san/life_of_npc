extends StaticBody2D

var suicide_saved: = 0

func _ready():
	$CollisionShape2D.disabled = true

func _on_suicide_prevention_trigger_body_entered(_body):
	$CollisionShape2D.set_deferred("disabled", false)
	Global.debug("Enabled Suicide Prevention")

func _on_suicide_zone_area_2d_body_entered(_body):
	suicide_saved += 1
	Global.debug("Suicide attempt detected.")
	Global.debug("Suicide prevented:" + str(suicide_saved))
