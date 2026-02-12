class_name AchievementsMenu extends Control

const INITIAL_Y: int = -200
const INITIAL_X: int = -100
const X_INCREMENT: int = 800
const Y_INCREMENT: int = 300

const ACH_PER_ROW: int = 2
const ROWS_PER_PAGE: int = 3
const _achievement_prefab: PackedScene = preload("res://Prefabs/achievement_unlocked.tscn")

static var page: int = 0

@onready var prev_button: Button = $PrevPage
@onready var next_button: Button = $NextPage
@onready var noob_text: Label = $Noob


func _ready() -> void:
	var x: int = INITIAL_X
	var y: int = INITIAL_Y
	
	var granted: Dictionary = Achievements.get_granted_achievements_info()
	var count: int = len(granted)
	noob_text.visible = count == 0
	
	var entries_per_page: int = ACH_PER_ROW * ROWS_PER_PAGE
	var page_start: int = page * entries_per_page
	var page_end: int = min(page_start + entries_per_page, count)
	
	for i in range(page_start, page_end):
		var dat: Dictionary = granted[granted.keys()[i]]
		var obj: AchievementBox = _achievement_prefab.instantiate()
		obj.dont_move = true
		obj.load_data(dat)
		obj.position.x = x
		obj.position.y = y
		add_child(obj)
		
		x += X_INCREMENT
		if (i+1) % ACH_PER_ROW == 0:
			y += Y_INCREMENT
			x = INITIAL_X
	
	prev_button.visible = page_start > 1
	next_button.visible = page_end < count


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")


func _on_prev_page_pressed() -> void:
	page -= 1
	get_tree().reload_current_scene()


func _on_next_page_pressed() -> void:
	page += 1
	get_tree().reload_current_scene()
