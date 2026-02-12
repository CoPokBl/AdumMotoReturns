class_name Spinny extends AnimatableBody2D

## Degrees per second
@export var speed: float = 1
@export var spin_left: bool = false
@export var wait_for_player: bool = false


func _physics_process(delta: float) -> void:
	if wait_for_player && !Utils.get_current_level().player.has_moved:
		return
	rotation_degrees += delta * speed * (-1 if spin_left else 1)
