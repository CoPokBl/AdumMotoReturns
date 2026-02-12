extends Node

const _data_path: String = "user://achievements.cfg"
const _box_prefab: PackedScene = preload("res://Prefabs/achievement_unlocked.tscn")

var _data: Dictionary
var _player_data: ConfigFile


func _ready() -> void:
	_data = JSON.parse_string(load_text_file("res://achievements.json"))
	
	_player_data = ConfigFile.new()
	_player_data.load(_data_path)


func grant(ach: String) -> void:
	if !_data.has(ach):
		return  # doesn't exist
	
	if _player_data.has_section_key("unlocked", ach):
		return  # already has
	
	# award
	_player_data.set_value("unlocked", ach, true)
	_player_data.save(_data_path)
	
	var box: AchievementBox = _box_prefab.instantiate()
	box.load_data(_data[ach])
	add_child(box)
	# will delete itself


func get_granted_achievements() -> PackedStringArray:
	if !_player_data.has_section("unlocked"):
		return [];
	return _player_data.get_section_keys("unlocked")


func get_achievement_info(ach: String) -> Dictionary:
	return _data[ach]


func get_granted_achievements_info() -> Dictionary:
	var granted: PackedStringArray = get_granted_achievements()
	var dat: Dictionary = {}
	for ach: String in granted:
		dat[ach] = get_achievement_info(ach)
	return dat


func load_text_file(path):
	var f = FileAccess.open(path, FileAccess.READ)
	var text = f.get_as_text()
	f.close()
	return text
