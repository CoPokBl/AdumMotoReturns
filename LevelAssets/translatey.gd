extends StaticBody2D

@export var time: float = 1  # time
@export var direction: Vector2 = Vector2.ZERO
@export var stationary_time: float = 0
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT
@export var trans: Tween.TransitionType = Tween.TRANS_LINEAR
@export var texture: Texture2D = preload("res://Assets/adum.png")
@export var wait_for_player: bool = false

var _start: Vector2
var _end: Vector2
var _tween: Tween


func _ready() -> void:
	$Sprite2D.texture = texture
	_start = position
	_end = position + direction
	
	if wait_for_player:
		Utils.get_current_level().player.first_move.connect(register_tweens)
	else:
		register_tweens()


func register_tweens() -> void:
	_tween = create_tween().set_loops().set_ease(ease_type).set_trans(trans) \
			.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.tween_interval(stationary_time)
	_tween.tween_property(self, "position", _end, time)
	_tween.tween_interval(stationary_time)
	_tween.tween_property(self, "position", _start, time)
