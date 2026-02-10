class_name Level extends Node2D

@export var number: int
@export var void_death_level: int = 2000
var reloading = false


func win():
	Utils.next_level()


func die():
	Utils.deaths += 1
	if not reloading:
		reloading = true
		call_deferred("reload")


func reload():
	get_tree().reload_current_scene()
