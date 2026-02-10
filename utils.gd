extends Node

const MAX_LEVEL: int = 1

var click_sound: AudioStreamOggVorbis = preload("res://Assets/click.ogg")

var deaths: int = 0  # reset on new level
var _sound_player: AudioStreamPlayer


# yes this script plays the sound.
# yep. The Utils script.
func _ready() -> void:
	var sound: PackedScene = ResourceLoader.load("res://epicness.tscn")
	add_child(sound.instantiate())
	
	_sound_player = AudioStreamPlayer.new()
	add_child(_sound_player)


func _process(delta: float) -> void:
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
	get_tree().change_scene_to_file("res://Levels/level" + str(num) + ".tscn")
	return true


func next_level() -> void:
	var current: int = get_current_level().number
	var possible: bool = load_level(current + 1)
	if !possible:
		# Win
		get_tree().quit()


func button_click() -> void:
	play_sfx(click_sound)


func play_sfx(sfx: AudioStreamOggVorbis) -> void:
	_sound_player.stop()
	_sound_player.stream = sfx
	_sound_player.play()
