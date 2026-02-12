extends Node

const SAVE_PATH: String = "user://save.cfg"
var MAX_LEVEL: int  # more like level count

var click_sound: AudioStreamOggVorbis = preload("res://Assets/click.ogg")

var deaths: int = 0  # reset on new level
var current_level: int = -1

var _sound_player: AudioStreamPlayer
var _loading_level: bool = false
var _save: ConfigFile


# yes this script plays the sound.
# yep. The Utils script.
func _ready() -> void:
	var filesinlevels: Array[String] = list_files_in_directory("res://Levels/")
	for file: String in filesinlevels:
		if file.ends_with(".tscn") && file.begins_with("level"):
			MAX_LEVEL += 1
	
	_save = ConfigFile.new()
	_save.load(SAVE_PATH)
	
	for v_name: String in ["Master", "Music", "Sounds"]:
		var idx: int = AudioServer.get_bus_index(v_name)
		AudioServer.set_bus_volume_linear(idx, Utils.get_save("volume", v_name.to_lower(), AudioServer.get_bus_volume_linear(idx)))
	
	var sound: PackedScene = ResourceLoader.load("res://Prefabs/epicness.tscn")
	add_child(sound.instantiate())
	
	_sound_player = AudioStreamPlayer.new()
	add_child(_sound_player)
	
	update_cursor()
	get_window().mode = Window.MODE_FULLSCREEN if get_save("window", "fullscreen", false) else Window.MODE_WINDOWED
	
	# process flags
	var level_to_load: int = -1
	
	var i: int = 0
	var flags: PackedStringArray = OS.get_cmdline_args()
	while i < len(flags):
		var flag: String = flags[i]
		
		match flag:
			"--level":
				level_to_load = int(flags[i+1])
				i += 1
		
		i += 1
	
	if level_to_load != -1:
		load_level(level_to_load)


func update_cursor():
	var texture: Texture2D
	var hotspot: Vector2
	if get_save("cursor", "center", false):
		texture = preload("res://Assets/center_ptr.png")
		hotspot = Vector2(17, 2)
	else:
		texture = preload("res://Assets/left_ptr.png")
		hotspot = Vector2(6, 6)
	
	DisplayServer.cursor_set_custom_image(texture, DisplayServer.CURSOR_ARROW, hotspot)


func list_files_in_directory(path):
	var files: Array[String] = []
	var dir: DirAccess = DirAccess.open(path)
	dir.list_dir_begin()

	while true:
		var file: String = dir.get_next()
		if file == "":
			break
		elif !file.begins_with("."):
			files.append(file)

	dir.list_dir_end()
	return files


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		button_click()


func get_current_level() -> Level:
	var scene = get_tree().current_scene
	if scene is Level:
		return scene
	return null


func load_level(num: int) -> bool:
	if num > MAX_LEVEL:
		return false
	deaths = 0
	
	if _loading_level:
		return false
	
	_loading_level = true
	current_level = num
	change_scene.call_deferred("res://Levels/level" + str(num) + ".tscn")
	return true


func change_scene(scene: String) -> void:
	_loading_level = false
	get_tree().change_scene_to_file(scene)


func win() -> void:
	_save.set_value("completed_levels", str(current_level), true)
	_save.save(SAVE_PATH)
	if len(_save.get_section_keys("completed_levels")) >= MAX_LEVEL:
		Achievements.grant("win")
	
	next_level()


func next_level() -> void:
	var current: int = current_level
	var possible: bool = load_level(current + 1)
	if !possible:
		# Win
		change_scene.call_deferred("res://Menus/main_menu.tscn")


func is_level_completed(level: int) -> bool:
	return _save.get_value("completed_levels", str(level), false)


# Play the next incomplete level
# or the first level.
func continue_levels() -> void:
	for i in range(1, MAX_LEVEL):
		if !is_level_completed(i):
			load_level(i)
	
	load_level(1)


func calc_game_completion() -> float:
	var completed_levels: int = 0
	for i in range(1, MAX_LEVEL+1):
		if is_level_completed(i):
			completed_levels += 1
	
	var levels_frac: float = float(completed_levels)/MAX_LEVEL
	var achievements_frac: float = float(len(Achievements.get_granted_achievements()))/len(Achievements._data)
	return (levels_frac + achievements_frac) / 2


func button_click() -> void:
	play_sfx(click_sound)


func play_sfx(sfx: AudioStreamOggVorbis, bus: StringName = "Sounds") -> void:
	_sound_player.stop()
	_sound_player.bus = bus
	_sound_player.stream = sfx
	_sound_player.play()


func set_save(section: String, key: String, value: Variant) -> void:
	_save.set_value(section, key, value)
	_save.save(SAVE_PATH)


func get_save(section: String, key: String, default: Variant = null) -> Variant:
	return _save.get_value(section, key, default)
