@tool
extends PanelContainer
class_name RepoDisplayer

var _name_text: RichTextLabel
var _path_text: RichTextLabel

var _name: String = ""
var _path: String = ""

func _ready():
	_name_text = get_node("%NameText")
	_path_text = get_node("%PathText")

	_name_text.clear()
	_name_text.append_text(_name)

	_path_text.clear()
	_path_text.append_text(_path)
