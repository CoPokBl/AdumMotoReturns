extends Node

const _box_prefab: PackedScene = preload("res://Prefabs/achievement_unlocked.tscn")

var _data: Dictionary
var _player_data: ConfigFile


func _ready() -> void:
	_data = JSON.parse_string(load_text_file("res://achievements.json"))
	
	_player_data = ConfigFile.new()
	_player_data.load("user://achievements.cfg")


func grant(ach: String) -> void:
	if !_data.has(ach):
		return  # doesn't exist
	
	if _player_data.has_section_key("unlocked", ach):
		return  # already has
	
	# award
	_player_data.set_value("unlocked", ach, true)
	
	var box: AchievementBox = _box_prefab.instantiate()
	box.load_data(_data[ach])
	add_child(box)
	# will delete itself


func load_text_file(path):
	var f = FileAccess.open(path, FileAccess.READ)
	var text = f.get_as_text()
	f.close()
	return text
