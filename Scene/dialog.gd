extends Control

var sounds:Array[AudioStreamPlayer]
var current_sound: AudioStreamPlayer
var rnd
var tween: Tween
const WORDS_PER_TWEEN = 40
const BOX_X_OFFSET = 50
const X_PER_LETTER = 10
const Y_PER_LINE = 35
const color_box_duration = 1

func _init():
	rnd = RandomNumberGenerator.new()

func _ready():
	for node in get_children():
		if node.get_class() == "AudioStreamPlayer":
			print("Loading: " + node.name)
			sounds.append(node as AudioStreamPlayer)
			

func set_dialog_animation(dialog_data, index:int=-1):
	rnd = RandomNumberGenerator.new()
	#Initialize the background
	var text_box = get_node("dialog_background_color") as ColorRect
	text_box.color = Color(dialog_data["color_background"])
	#Initialize the label
	var text_label = get_node("TextLabel") as RichTextLabel
	text_label.clear()
	var text
	if index == -1:
		text = dialog_data.text[rnd.randi_range(0, dialog_data.text.size()-1)]
	else:
		text = dialog_data.text[index]
	text = text.replace("\t", "")
	text_label.append_text("[center]"+ text + "[/center]")
	##Initilize the box size and prep tween variables
	text_box.custom_minimum_size = Vector2.ZERO
	var text_duration = text.length() / WORDS_PER_TWEEN
	var box_hight = (1+ text.count("\n")) * Y_PER_LINE
	var box_width = 0.0
	for line in text.split("\n"):
		box_width = clamp(line.length() * X_PER_LETTER, box_width, 3000)
	var target_box_size = Vector2(box_width + BOX_X_OFFSET, box_hight)
	#Show one letter at a time while increasing the size of the box
	text_label.visible_ratio = 0
	if tween: 
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(text_box, "custom_minimum_size", target_box_size, color_box_duration)
	tween.parallel().tween_property(text_label, "visible_ratio", 1, text_duration)	
	var sound = play_dialog_sound()
	tween.finished.connect(sound.stop)

func playing_dialog() -> bool:
	return tween.is_running()

func play_dialog_sound() -> AudioStreamPlayer:
	if current_sound:
		current_sound.stop()
	rnd = RandomNumberGenerator.new()
	current_sound = sounds[rnd.randi_range(0, sounds.size()-1)]
	current_sound.play()
	return current_sound

func abort_dialog_animation():
	if tween: 
		tween.kill()
		get_tree().create_tween()
	get_node("Speech_background_color").custom_minimum_size = Vector2.ZERO
