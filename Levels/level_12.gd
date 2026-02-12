extends Level


func _win():
	if player.has_moved:
		Achievements.grant("inputinauto")
	return true
