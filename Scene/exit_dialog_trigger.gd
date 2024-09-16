extends "res://Scene/dialog_trigger.gd"

func _on_body_entered(body):
	if not Global.player.ate_shroom:
		super(body)
