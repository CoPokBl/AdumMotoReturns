extends Control


func _on_play_pressed() -> void:
	Utils.load_level(1)


func _on_level_select_pressed() -> void:
	LevelSelect.page = 0
	get_tree().change_scene_to_file("res://Menus/level_select.tscn")


func _on_achievements_pressed() -> void:
	AchievementsMenu.page = 0
	get_tree().change_scene_to_file("res://Menus/achievements_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
