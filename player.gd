class_name Player extends Node2D

const SPEED: float = 5000
const TILT_SPEED: float = 700_000
const ZOOM: float = 0.65

@onready var body: RigidBody2D = $Body
@onready var camera: Camera2D = $FeetCam


func _ready() -> void:
	%LevelName.text = "Level " + str(Utils.get_current_level().number)
	%CloudParallax.autoscroll.x = randfn(-10, 15)
	visible = true


func _process(_delta: float) -> void:
	%CloudParallax.position.y = position.y


func _physics_process(_delta: float) -> void:
	%DeathsLabel.text = "Deaths: " + str(Utils.deaths)
	
	if Input.is_action_pressed("forward"):
		body.apply_central_force(Vector2(SPEED, 0))
	
	if Input.is_action_pressed("backward"):
		body.apply_central_force(Vector2(-SPEED, 0))
	
	if Input.is_action_pressed("tilt_left"):
		body.apply_torque(-TILT_SPEED)
	
	if Input.is_action_pressed("tilt_right"):
		body.apply_torque(TILT_SPEED)
	
	# Void death
	# adum says it's important
	if body.position.y > Utils.get_current_level().void_death_level:
		Utils.get_current_level().die()


func _on_head_hurt_body_entered(ebody: Node2D) -> void:
	if ebody.get_parent() is Player:
		return
	
	Utils.get_current_level().die()


func _on_menu_pressed() -> void:
	Utils.change_scene("res://Menus/main_menu.tscn")


func _on_restart_pressed() -> void:
	Utils.get_current_level().die()
