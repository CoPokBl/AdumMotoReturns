extends AnimatableBody2D

@export var point: Node2D
@export var speed: float = 1
@export var wait_for_player: bool = false

var _time: float = 0
var _radius: float


func _ready() -> void:
	_radius = position.length()
	_time = position.angle()


func _process(delta: float) -> void:
	if wait_for_player && !Utils.get_current_level().player.has_moved:
		return
	
	_time += delta * speed
	position = Vector2(_radius * sin(_time), _radius * cos(_time))
