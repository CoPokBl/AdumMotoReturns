extends Control

@onready var master_volume = %MasterVolume
@onready var music_volume = %MusicVolume
@onready var sounds_volume = %SoundsVolume


func _ready() -> void:
	master_volume.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master"))
	music_volume.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Music"))
	sounds_volume.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Sounds"))


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
