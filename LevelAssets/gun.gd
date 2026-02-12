extends StaticBody2D

@export var shoot_time: float = 3
@export var bullet_speed: float = 5000
@export var spread: float = 300
@export var bullet_despawn_time: float = 5

@onready var timer: Timer = $Timer

const bullet_prefab: PackedScene = preload("res://Prefabs/bullet.tscn")
const START_POS: Vector2 = Vector2(-4, -43)


func _ready() -> void:
	timer.wait_time = shoot_time
	timer.timeout.connect(shoot)
	timer.start()


func shoot() -> void:
	var bullet: Bullet = bullet_prefab.instantiate()
	bullet.position = START_POS
	bullet.despawn_time = bullet_despawn_time
	add_child(bullet)
	bullet.apply_central_impulse(Vector2(randf_range(-spread, spread), -bullet_speed))
