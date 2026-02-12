extends Control

@onready var completion_label: Label = $Completion


func _ready() -> void:
	completion_label.text = "Game Completion: " + str(round(Utils.calc_game_completion()*100)) + "%"


func _on_play_pressed() -> void:
	Utils.continue_levels()


func _on_level_select_pressed() -> void:
	LevelSelect.page = 0
	get_tree().change_scene_to_file("res://Menus/level_select.tscn")


func _on_achievements_pressed() -> void:
	AchievementsMenu.page = 0
	get_tree().change_scene_to_file("res://Menus/achievements_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/options_menu.tscn")
