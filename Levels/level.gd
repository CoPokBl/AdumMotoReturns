class_name Level extends Node2D

const DEATH_TIME: float = 0.5

@export var number: int
@export var void_death_level: int = 2000
@export var player: Player

var dead: bool = false


func win():
	if dead:
		Achievements.grant("winwhiledead")
	Utils.next_level()


func die(skip_animation: bool = false):
	if dead:
		return
	
	dead = true
	player.die()
	Utils.deaths += 1
	
	if skip_animation:
		reload.call_deferred()
		return
	get_tree().create_timer(DEATH_TIME).timeout.connect(reload)


func reload():
	get_tree().reload_current_scene()
