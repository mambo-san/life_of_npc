extends Node

#Use this script to translate e.g. initialize locale variable and modify JSON structure
const DIALOG_FILE_PATH = "res://src/dialogs.json"
const TAG_BACKGROUND_COLOR = "color_background"
const TAG_TEXT = "text"
var dialog_dict
var locale #TODO

func _ready():
	var json_as_text = FileAccess.get_file_as_string(DIALOG_FILE_PATH)
	dialog_dict = JSON.parse_string(json_as_text)

func get_dialog_text(key:String, index:int=-1):
	if index ==-1:
		return dialog_dict[key]
	
	var dialog_data = dialog_dict[key]
	var dialog_one_data = {}
	dialog_one_data[TAG_BACKGROUND_COLOR] = dialog_data[TAG_BACKGROUND_COLOR]
	dialog_one_data[TAG_TEXT] =  [dialog_data[TAG_TEXT][index]]
	return dialog_one_data
