extends Control


func _ready() -> void:
	var best_time: float = Utils.get_save("speedrun", "best", -1)
	var levels: int = Utils.get_save("speedrun", "levels", 0)
	var outdated: bool = levels != Utils.MAX_LEVEL
	%Run.text = "No completions yet." if best_time == -1 else \
		"Best time: " + ("[OUTDATED] " if outdated else "") \
		+ Stopwatch.format_time(best_time)
	
	# level times
	for i: int in range(1, Utils.MAX_LEVEL+1):
		var time: float = Utils.get_save("level_times", "level" + str(i), -1)
		var timestr: String = "N/A" if time == -1 else Stopwatch.format_time(time)
		%Run.text += "\n" + "Level " + str(i) + ": " + timestr


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")


func _on_new_run_pressed() -> void:
	Utils.start_speedrun()
