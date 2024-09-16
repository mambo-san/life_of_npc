extends CanvasLayer

func _ready():
	Global.HUD_canvas = self
	
#Functions to manage User Interfaces scene
func enable_dialog(dialog_key: String):
	Global.debug("Fetching random dialog:" + dialog_key)
	if dialog_key.is_empty():
		dialog_key = "no_text_not_found_404"
	var dialog_data = DialogTexts.get_dialog_text(dialog_key)
	$DialogPanel.set_dialog_animation(dialog_data)
	$DialogPanel.visible = true

func enable_dialog_with_index(dialog_key: String, index):
	Global.debug("Fetching one dialog:" + dialog_key)
	if dialog_key.is_empty():
		dialog_key = "no_text_not_found_404"
	var dialog_data = DialogTexts.get_dialog_text(dialog_key, index)
	$DialogPanel.set_dialog_animation(dialog_data)
	$DialogPanel.visible = true

	

func disable_dialog():
	$DialogPanel.visible = false
