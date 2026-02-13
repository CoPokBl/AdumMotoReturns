extends Camera2D

var dragging := false

@export var zoom_speed := 0.1
@export var min_zoom := -10
@export var max_zoom := 10

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			dragging = event.pressed
	
	if event is InputEventMouseMotion and dragging:
		position -= event.relative / zoom
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_camera(zoom_speed)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_camera(-zoom_speed)

func zoom_camera(amount: float):
	var mouse_pos = get_global_mouse_position()
	var new_zoom = zoom + Vector2(amount, amount)
	
	new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
	new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)
	
	zoom = new_zoom
	
	var mouse_offset = mouse_pos - get_global_mouse_position()
	position += mouse_offset
