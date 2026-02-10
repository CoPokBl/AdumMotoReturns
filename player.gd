class_name Player extends RigidBody2D

const SPEED: float = 18000
const TILT_SPEED: float = 700_000


func _ready() -> void:
	%LevelName.text = "Level " + str(Utils.get_current_level().number)
	%CloudParallax.autoscroll.x = randfn(-10, 15)


func _process(_delta: float) -> void:
	%CloudParallax.position.y = position.y


func _physics_process(delta: float) -> void:
	%DeathsLabel.text = "Deaths: " + str(Utils.deaths)
	
	if Input.is_action_pressed("forward"):
		apply_central_force(Vector2(SPEED, 0))
	
	if Input.is_action_pressed("backward"):
		apply_central_force(Vector2(-SPEED, 0))
	
	if Input.is_action_pressed("tilt_left"):
		apply_torque(-TILT_SPEED)
	
	if Input.is_action_pressed("tilt_right"):
		apply_torque(TILT_SPEED)
	
	# Void death
	# adum says it's important
	if position.y > Utils.get_current_level().void_death_level:
		Utils.get_current_level().die()


func _on_head_hurt_body_entered(body: Node2D) -> void:
	if body is Player:
		return
	
	Utils.get_current_level().die()
