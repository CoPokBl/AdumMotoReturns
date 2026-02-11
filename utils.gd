extends Node

const MAX_LEVEL: int = 2  # more like level count

var click_sound: AudioStreamOggVorbis = preload("res://Assets/click.ogg")

var deaths: int = 0  # reset on new level

var _sound_player: AudioStreamPlayer
var _loading_level: bool = false


# yes this script plays the sound.
# yep. The Utils script.
func _ready() -> void:
	var sound: PackedScene = ResourceLoader.load("res://Prefabs/epicness.tscn")
	add_child(sound.instantiate())
	
	_sound_player = AudioStreamPlayer.new()
	add_child(_sound_player)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		button_click()


func get_current_level() -> Level:
	var scene = get_tree().current_scene
	if scene is Level:
		return scene
	return null


# Perfectly good function with no jank
func load_level(num: int) -> bool:
	if num > MAX_LEVEL:
		return false
	deaths = 0
	
	if _loading_level:
		return false
	
	_loading_level = true
	change_scene.call_deferred("res://Levels/level" + str(num) + ".tscn")
	return true


func change_scene(scene: String) -> void:
	_loading_level = false
	get_tree().change_scene_to_file(scene)


func next_level() -> void:
	var current: int = get_current_level().number
	var possible: bool = load_level(current + 1)
	if !possible:
		# Win
		Achievements.grant("win")
		change_scene.call_deferred("res://Menus/main_menu.tscn")


func button_click() -> void:
	play_sfx(click_sound)


func play_sfx(sfx: AudioStreamOggVorbis) -> void:
	_sound_player.stop()
	_sound_player.stream = sfx
	_sound_player.play()
