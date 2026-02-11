extends StaticBody2D

@export var time: float = 1  # time
@export var direction: Vector2 = Vector2.ZERO
@export var stationary_time: float = 0

var _start: Vector2
var _end: Vector2
var _tween: Tween


func _ready() -> void:
	_start = position
	_end = position + direction
	_tween = create_tween()
	_tween.set_loops()
	_tween.tween_interval(stationary_time)
	_tween.tween_property(self, "position", _end, time)
	_tween.tween_interval(stationary_time)
	_tween.tween_property(self, "position", _start, time)
