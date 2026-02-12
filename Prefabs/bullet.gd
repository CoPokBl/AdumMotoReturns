class_name Bullet extends RigidBody2D

@onready var despawn_timer: Timer = $DespawnTimer

var despawn_time: float


func _ready() -> void:
	despawn_timer.timeout.connect(queue_free)
	despawn_timer.start(despawn_time)


func _on_body_entered(body: Node) -> void:
	if body.get_parent() is Player:
		Utils.get_current_level().die()
