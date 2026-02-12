extends Area2D

@export var uses = 5

func _on_body_entered(body: Node2D) -> void:
	if body.get_parent() is Player:
		Utils.get_current_level().player.helmet_uses = uses
		Utils.get_current_level().player.hat.visible = true
		queue_free()
