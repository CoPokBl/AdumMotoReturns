extends Level

func _win():
	if player.helmet_uses > 0:
		Achievements.grant("hardhatwheel")
	
	return true
