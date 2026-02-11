class_name LevelSelect extends Control

const INITIAL_Y: int = 200
const INITIAL_X: int = 250
const LEVELS_PER_ROW: int = 5
const ROWS_PER_PAGE: int = 4
const _level_button: PackedScene = preload("res://Menus/level_button.tscn")

static var page: int = 0

@onready var prev_button: Button = $PrevPage
@onready var next_button: Button = $NextPage


func _ready() -> void:
	var x: int = INITIAL_X
	var y: int = INITIAL_Y
	
	var level_count: int = Utils.MAX_LEVEL
	var entries_per_page: int = LEVELS_PER_ROW * ROWS_PER_PAGE
	var page_start: int = page * entries_per_page + 1
	var page_end: int = min(page_start + entries_per_page - 1, level_count)
	
	for i in range(page_start, page_end + 1):
		var obj: Button = _level_button.instantiate()
		obj.text = "Level " + str(i)
		obj.pressed.connect(func():
			Utils.load_level(i)
		)
		obj.position.x = x
		obj.position.y = y
		add_child(obj)
		x += 300
		if i % LEVELS_PER_ROW == 0:
			y += 200
			x = INITIAL_X
	
	prev_button.visible = page_start > 1
	next_button.visible = page_end < level_count


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")


func _on_prev_page_pressed() -> void:
	page -= 1
	get_tree().reload_current_scene()


func _on_next_page_pressed() -> void:
	page += 1
	get_tree().reload_current_scene()
