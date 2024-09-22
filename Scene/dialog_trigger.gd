extends Area2D

var HUD_canvas

func _ready():
	HUD_canvas = Global.HUD_canvas

func _on_body_entered(_body):
	Global.debug(str(_body.name) + " entered " + name)
	HUD_canvas.enable_dialog(self.name)


func _on_body_exited(_body):
	Global.debug(str(_body.name) + " exited " + name)
	HUD_canvas.disable_dialog()
