extends Control

@onready var warning: Control = %Warning
@onready var tool_buttons: CenterContainer = %ToolButtons
@onready var editor_items: Node2D = %EditorItems
@onready var mode_label: Label = %Mode

@onready var mouse_area: Area2D = %Area2D

var platform_object: PackedScene = preload("res://LevelAssets/platform.tscn")
var platform_cold_object: PackedScene = preload("res://LevelAssets/cold_platform.tscn")
var platform_bouncy_object: PackedScene = preload("res://LevelAssets/bouncy_platform.tscn")
var gun_object: PackedScene = preload("res://LevelAssets/gun.tscn")
var helmet_object: PackedScene = preload("res://LevelAssets/helmet_item.tscn")
var rotatey_around_point_object: PackedScene = preload("res://LevelAssets/rotatey_around_point.tscn")
var speed_bump_object: PackedScene = preload("res://LevelAssets/speed_bump.tscn")
var spinny_object: PackedScene = preload("res://LevelAssets/Spinny.tscn")
var translatey_object: PackedScene = preload("res://LevelAssets/translatey.tscn")
var win_object: PackedScene = preload("res://LevelAssets/win.tscn")

const GRABBY_ORB = preload("uid://d28qe3jrwysey")

enum MOUSE_MODE {
	SELECTION,
	ALL_MODE,
	MOVE_OBJECT,
	SCALE_OBJECT,
	ROTATE_OBJECT,
	PLACE_OBJECT
}

const MOUSE_MODE_NAMES = {
	MOUSE_MODE.SELECTION: "Selection",
	MOUSE_MODE.ALL_MODE: "Global",
	MOUSE_MODE.MOVE_OBJECT: "Move Object",
	MOUSE_MODE.SCALE_OBJECT: "Scale Object",
	MOUSE_MODE.ROTATE_OBJECT: "Rotate Object",
	MOUSE_MODE.PLACE_OBJECT: "Place Object"
}

var item_on_mouse: PackedScene
var item_on_mouse_in_move_mode: Node2D
var selected_object: Node2D
var old_modulate: Color
var mouse_mode: MOUSE_MODE = MOUSE_MODE.SELECTION
var last_mouse_mode: MOUSE_MODE = mouse_mode
var drag_offset: Vector2 = Vector2.ZERO 

# scale mode variables
var scale_handles: Array[Node2D] = []
var active_scale_handle: Node2D = null
var original_scale: Vector2 = Vector2.ONE
var original_position: Vector2 = Vector2.ZERO
var scale_start_mouse_pos: Vector2 = Vector2.ZERO
var anchor_point: Vector2 = Vector2.ZERO

# rotation mode variables
var is_rotating: bool = false
var rotation_start_angle: float = 0.0
var object_start_rotation: float = 0.0

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("selection"):
		_clear_scale_handles()
		mouse_mode = MOUSE_MODE.SELECTION
	elif Input.is_action_just_pressed("move_object"):
		_clear_scale_handles()
		mouse_mode = MOUSE_MODE.MOVE_OBJECT
	elif Input.is_action_just_pressed("scale_object"):
		mouse_mode = MOUSE_MODE.SCALE_OBJECT
		if selected_object != null:
			_create_scale_handles()
	elif Input.is_action_just_pressed("rotate_object"):
		_clear_scale_handles()
		mouse_mode = MOUSE_MODE.ROTATE_OBJECT
	elif Input.is_action_just_pressed("all_mode"):
		_clear_scale_handles()
		mouse_mode = MOUSE_MODE.ALL_MODE
	
	if Input.is_action_just_pressed("exit_place_mode"):
		mouse_mode = last_mouse_mode
		if item_on_mouse != null:
			item_on_mouse = null
	
	if mouse_mode == MOUSE_MODE.ALL_MODE:
		for child in editor_items.get_children():
			pass
	
	if mouse_mode == MOUSE_MODE.MOVE_OBJECT && item_on_mouse_in_move_mode != null:
		item_on_mouse_in_move_mode.global_position = get_global_mouse_position() + drag_offset
	
	if mouse_mode == MOUSE_MODE.SCALE_OBJECT && active_scale_handle != null && selected_object != null:
		_update_scale()
	
	if mouse_mode == MOUSE_MODE.SCALE_OBJECT && selected_object != null:
		_update_handle_positions()
	
	if mouse_mode == MOUSE_MODE.ROTATE_OBJECT && is_rotating && selected_object != null:
		_update_rotation()
	
	mouse_area.global_position = get_global_mouse_position()
	mode_label.text = MOUSE_MODE_NAMES[mouse_mode]


func _on_warning_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if mouse_mode == MOUSE_MODE.MOVE_OBJECT and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if item_on_mouse_in_move_mode == null:
					var bodies = mouse_area.get_overlapping_bodies()
					if bodies.size() > 0:
						item_on_mouse_in_move_mode = bodies[0]
						drag_offset = item_on_mouse_in_move_mode.global_position - get_global_mouse_position()
			else:
				item_on_mouse_in_move_mode = null
			
		elif mouse_mode == MOUSE_MODE.SELECTION:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					var bodies = mouse_area.get_overlapping_bodies()
					if bodies.size() > 0:
						var new_selection = bodies[0]
						if selected_object != null and selected_object != new_selection:
							selected_object.modulate = old_modulate
						
						if selected_object != new_selection:
							selected_object = new_selection
							old_modulate = selected_object.modulate
							selected_object.modulate = Color(0.0, 0.994, 0.925, 0.784)
					else:
						if selected_object != null:
							selected_object.modulate = old_modulate
							selected_object = null
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				for object in mouse_area.get_overlapping_bodies():
					object.queue_free()
					return
			
		elif mouse_mode == MOUSE_MODE.SCALE_OBJECT:
			if event.button_index == MOUSE_BUTTON_LEFT:
				active_scale_handle = _get_handle_at_mouse()
				if active_scale_handle != null && selected_object != null:
					var dir = active_scale_handle.get_meta("scale_direction")
					var pivot_local = Vector2.ZERO
					
					match dir:
						"left": pivot_local = Vector2(40, 0)
						"right": pivot_local = Vector2(-40, 0)
						"top": pivot_local = Vector2(0, 40)
						"bottom": pivot_local = Vector2(0, -40)
				
					anchor_point = selected_object.to_global(pivot_local)
			else:
				active_scale_handle = null
			
		elif mouse_mode == MOUSE_MODE.ROTATE_OBJECT:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					var bodies = mouse_area.get_overlapping_bodies()
					if selected_object != null && selected_object in bodies:
						is_rotating = true
						var mouse_pos = get_global_mouse_position()
						var object_pos = selected_object.global_position
						rotation_start_angle = (mouse_pos - object_pos).angle()
						object_start_rotation = selected_object.global_rotation
				else:
					is_rotating = false
		
		if item_on_mouse != null:
			if event.pressed:
				var object = item_on_mouse.instantiate()
				object.global_position = get_local_mouse_position()
				editor_items.add_child(object)
				item_on_mouse = null
				mouse_mode = last_mouse_mode


func _update_rotation() -> void:
	if selected_object == null:
		return
	
	var mouse_pos = get_global_mouse_position()
	var object_pos = selected_object.global_position
	var current_angle = (mouse_pos - object_pos).angle()
	var angle_delta = current_angle - rotation_start_angle
	
	selected_object.global_rotation = object_start_rotation + angle_delta


func _create_scale_handles() -> void:
	_clear_scale_handles()
	
	if selected_object == null:
		return
	
	scale_handles.append(_create_grabby_point(selected_object, Vector2(-40, 0), "left"))
	scale_handles.append(_create_grabby_point(selected_object, Vector2(40, 0), "right"))
	scale_handles.append(_create_grabby_point(selected_object, Vector2(0, -40), "top"))
	scale_handles.append(_create_grabby_point(selected_object, Vector2(0, 40), "bottom"))


func _clear_scale_handles() -> void:
	for handle in scale_handles:
		if is_instance_valid(handle):
			handle.queue_free()
	scale_handles.clear()
	active_scale_handle = null


func _create_grabby_point(object: Node2D, offset: Vector2, direction: String) -> Node2D:
	var point: Node2D = Node2D.new()
	point.position = offset
	point.set_meta("scale_direction", direction)
	
	var area: Area2D = Area2D.new()
	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = 10.0
	collision.shape = shape
	area.add_child(collision)
	point.add_child(area)
	
	var point_texture: Sprite2D = Sprite2D.new()
	point_texture.texture = GRABBY_ORB
	
	point.add_child(point_texture)
	object.add_child(point)
	
	return point


func _get_handle_at_mouse() -> Node2D:
	for area in mouse_area.get_overlapping_areas():
		var parent = area.get_parent()
		if parent in scale_handles:
			return parent
	
	return null


func _update_scale() -> void:
	if selected_object == null || active_scale_handle == null:
		return
	
	var direction = active_scale_handle.get_meta("scale_direction")
	var current_mouse = get_global_mouse_position()
	var vector_to_mouse = current_mouse - anchor_point
	
	var object_rotation = selected_object.global_rotation
	var axis_vector = Vector2.ZERO
	
	if direction == "left" or direction == "right":
		axis_vector = Vector2.RIGHT.rotated(object_rotation)
	else:
		axis_vector = Vector2.UP.rotated(object_rotation)
	

	var new_length = vector_to_mouse.dot(axis_vector)
	var new_scale_val = abs(new_length) / 80.0
	new_scale_val = max(new_scale_val, 0.1)
	
	if direction == "left" or direction == "right":
		selected_object.scale.x = new_scale_val
	else:
		selected_object.scale.y = new_scale_val

	var projected_handle_pos = anchor_point + (axis_vector * new_length)
	selected_object.global_position = (anchor_point + projected_handle_pos) / 2.0


func _update_handle_positions() -> void:
	if selected_object == null:
		return
	
	for handle in scale_handles:
		if is_instance_valid(handle):
			handle.scale = Vector2.ONE / selected_object.scale


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")


func _on_load_pressed() -> void:
	tool_buttons.visible = true
	warning.visible = false


func _on_create_pressed() -> void:
	tool_buttons.visible = true
	warning.visible = false


func _change_mouse_mode_button_click() -> void:
	if mouse_mode != MOUSE_MODE.PLACE_OBJECT:
		last_mouse_mode = mouse_mode
	mouse_mode = MOUSE_MODE.PLACE_OBJECT


func _on_button_button_down() -> void:
	_change_mouse_mode_button_click()
	item_on_mouse = platform_object


func _on_button_2_button_down() -> void:
	_change_mouse_mode_button_click()
	item_on_mouse = platform_cold_object


func _on_button_3_button_down() -> void:
	_change_mouse_mode_button_click()
	item_on_mouse = platform_bouncy_object


func _on_button_4_button_down() -> void:
	_change_mouse_mode_button_click()
	item_on_mouse = gun_object


func _on_button_5_button_down() -> void:
	_change_mouse_mode_button_click()
	item_on_mouse = helmet_object


func _on_button_6_button_down() -> void:
	_change_mouse_mode_button_click()
	item_on_mouse = rotatey_around_point_object


func _on_button_7_button_down() -> void:
	_change_mouse_mode_button_click()
	item_on_mouse = speed_bump_object


func _on_button_8_button_down() -> void:
	_change_mouse_mode_button_click()
	item_on_mouse = spinny_object


func _on_button_9_button_down() -> void:
	_change_mouse_mode_button_click()
	item_on_mouse = translatey_object


func _on_button_10_button_down() -> void:
	_change_mouse_mode_button_click()
	item_on_mouse = win_object
