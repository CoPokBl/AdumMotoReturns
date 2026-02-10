extends Node

const MAX_LEVEL: int = 1

var deaths: int = 0  # reset on new level


# yes this script plays the sound.
# yep. The Utils script.
func _ready() -> void:
	var sound: PackedScene = ResourceLoader.load("res://epicness.tscn")
	add_child(sound.instantiate())


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
