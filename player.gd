class_name Player extends Node2D

enum ControlMode {
	NORMAL,
	WHEEL
}

const SPEED: float = 5000
const TILT_SPEED: float = 500_000
const ZOOM: float = 0.65

signal first_move

@onready var body: RigidBody2D = $Body
@onready var camera: Camera2D = $Cam
@onready var dead_colour: ColorRect = $Cam/UI/DeadColour
@onready var hat: Sprite2D = $Body/Hat

# control type packs
@onready var normal_mode_pack: Node2D = $Body/Normal
@onready var wheel_mode_pack: Node2D = $Body/Wheel

# per level settings
@export var helmet_uses: int = 0
@export var control_mode: ControlMode = ControlMode.NORMAL

var dead: bool = false
var has_moved: bool = false


func _ready() -> void:
	%LevelName.text = "Level " + str(Utils.get_current_level().number)
	%CloudParallax.autoscroll.x = randfn(-10, 15)
	visible = true
	
	var packs: Array[Node2D] = [
		normal_mode_pack,
		wheel_mode_pack
	]
	
	var active_pack: Node2D
	match control_mode:
		ControlMode.NORMAL:
			active_pack = normal_mode_pack
			body.physics_material_override.friction = 0.3
		ControlMode.WHEEL:
			active_pack = wheel_mode_pack
			body.physics_material_override.friction = 1
	
	for child: Node in active_pack.get_children():
		child.reparent(body)
	
	for pack: Node2D in packs:
		pack.queue_free()
	
	if !Utils.speedrunning && !Utils.get_save("gameplay", "level_timer", false):
		%SpeedrunTimer.visible = false


func _process(_delta: float) -> void:
	%CloudParallax/Cloud.position.y = body.position.y
	
	if Utils.speedrunning:
		%SpeedrunTimer.text = Utils.speedrunning_stopwatch.get_time_string()
	else:
		%SpeedrunTimer.text = Utils.get_current_level().clock.get_time_string()


func _physics_process(_delta: float) -> void:
	%DeathsLabel.text = "Deaths: " + str(Utils.deaths)
	
	if dead:
		return
	
	if helmet_uses == 0:
		hat.visible = false
	
	if control_mode == ControlMode.NORMAL:
		if Input.is_action_pressed("forward"):
			_moved()
			body.apply_central_force(Vector2(SPEED, 0))
		
		if Input.is_action_pressed("backward"):
			_moved()
			body.apply_central_force(Vector2(-SPEED, 0))
	
	if Input.is_action_pressed("tilt_left"):
		_moved()
		body.apply_torque(-TILT_SPEED)
	
	if Input.is_action_pressed("tilt_right"):
		_moved()
		body.apply_torque(TILT_SPEED)
	
	# Void death
	# adum says it's important
	if body.position.y > Utils.get_current_level().void_death_level:
		Utils.get_current_level().die()


func _moved() -> void:
	if has_moved:
		return
	
	has_moved = true
	first_move.emit()


# Perform death animation
func die() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(dead_colour, "modulate", Color.WHITE, Level.DEATH_TIME)
	dead = true


func _on_head_hurt_body_entered(ebody: Node2D) -> void:
	if ebody.get_parent() is Player:
		return
	
	if control_mode == ControlMode.WHEEL:
		return  # don't have head
	
	if helmet_uses > 0:
		helmet_uses -= 1;
		return
	
	Utils.get_current_level().die()


func _on_menu_pressed() -> void:
	Utils.change_scene("res://Menus/main_menu.tscn")


func _on_restart_pressed() -> void:
	Utils.get_current_level().die(true)
