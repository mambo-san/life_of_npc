extends Node

@onready var BGM = $BGM as AudioStreamPlayer
@onready var chill = $Chill_music as AudioStreamPlayer
@onready var pickup
@onready var dialog

var current_music: AudioStreamPlayer

func _ready():
	Global.sound_manager = self
	$BGM.finished.connect(replay.bind($BGM))
	$Chill_music.finished.connect(replay.bind($Chill_music))

func changeMusic(music_name :String):
	var next_music : AudioStreamPlayer
	for node in get_children():
		if node.name == music_name:
			next_music = node
	
	if not current_music:
		next_music.play()
		current_music = next_music
	else:
		current_music.stop()
	
	if next_music:
		next_music.play()
		current_music = next_music
	else:
		push_warning("Music not found: " + music_name)
	
func playSound(sound_name :String):
	var sound_node : AudioStreamPlayer
	for node in get_children():
		if node.name == sound_name:
			sound_node = node
	
	if sound_node:
		sound_node.play()
	else:
		push_warning("Sound not found: " + sound_name)

func replay(music_name: AudioStreamPlayer):
	music_name.play()
