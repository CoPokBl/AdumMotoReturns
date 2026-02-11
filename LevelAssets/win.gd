extends Area2D

@export var grant_achievements: Array[String] = []


func _on_body_entered(body: Node2D) -> void:
	if body.get_parent() is Player:
		Utils.get_current_level().win()
	
	for ach: String in grant_achievements:
		Achievements.grant(ach)
