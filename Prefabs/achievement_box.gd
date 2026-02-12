class_name AchievementBox extends Control

@onready var display: Control = $Display

var dont_move: bool = false


func load_data(data: Dictionary) -> void:
	%Title.text = data["title"]
	%Desc.text = data["desc"]


func _ready() -> void:
	if dont_move:
		return
	
	var initial_pos: Vector2 = display.position
	display.position = Vector2(display.position.x + 800, display.position.y)
	var tween: Tween = create_tween()
	tween.tween_property(display, "position", initial_pos, 0.5)
	
	get_tree().create_timer(5).timeout.connect(func():
		var tween_out: Tween = create_tween()
		tween_out.tween_property(display, "position", Vector2(initial_pos.x + 800, initial_pos.y), 1.0)
		tween_out.tween_callback(queue_free)
	)


func _process(_delta: float) -> void:
	if dont_move:
		return
	
	var level: Level = Utils.get_current_level()
	if level == null:
		global_position = Vector2(960, 540)
		return
	
	scale = Vector2.ONE/Utils.get_current_level().player.camera.zoom
	global_position = level.player.camera.global_position
