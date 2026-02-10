class_name Die extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		Utils.get_current_level().die()
