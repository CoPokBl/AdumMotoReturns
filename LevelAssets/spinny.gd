class_name Spinny extends AnimatableBody2D

## Degrees per second
@export var speed: float = 1
@export var spin_left: bool = false


func _physics_process(delta: float) -> void:
	rotation_degrees += delta * speed * (-1 if spin_left else 1)
