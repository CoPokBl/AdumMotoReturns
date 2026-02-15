extends Control

@onready var master_volume = %MasterVolume
@onready var music_volume = %MusicVolume
@onready var sounds_volume = %SoundsVolume
@onready var center_cursor: CheckBox = %CenterCursor
@onready var fullscreen: CheckBox = %Fullscreen
@onready var level_timer: CheckBox = %LevelTimer


func _ready() -> void:
	master_volume.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master"))
	music_volume.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Music"))
	sounds_volume.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Sounds"))
	center_cursor.button_pressed = Utils.get_save("cursor", "center", false)
	fullscreen.button_pressed = Utils.get_save("window", "fullscreen", false)
	level_timer.button_pressed = Utils.get_save("gameplay", "level_timer", false)


func _on_master_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)
	Utils.set_save("volume", "master", value)


func _on_music_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), value)
	Utils.set_save("volume", "music", value)


func _on_sound_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Sounds"), value)
	Utils.set_save("volume", "sounds", value)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")


func _on_center_cursor_toggled(value: bool) -> void:
	Utils.set_save("cursor", "center", value)
	Utils.update_cursor()


func _on_fullscreen_toggled(value: bool) -> void:
	Utils.set_save("window", "fullscreen", value)
	get_window().mode = Window.MODE_FULLSCREEN if value else Window.MODE_WINDOWED


func _on_level_timer_toggled(toggled_on: bool) -> void:
	Utils.set_save("gameplay", "level_timer", toggled_on)
