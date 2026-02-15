extends Label


func _ready() -> void:
	if Utils.speedrunning:
		text = "Press Shift + 'R' to restart speedrun"
