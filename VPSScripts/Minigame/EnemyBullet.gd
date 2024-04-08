extends Area2D

var paused: bool = false
var velocity: Vector2
var real_position: Vector2

func _ready():
	real_position = position


func _process(delta):
	if not paused:
		move(delta)
		position = Vector2(round(real_position.x), round(real_position.y))

func set_velocity(newVelocity):
	velocity = newVelocity

func move(delta):
	real_position += delta * velocity

func pause():
	paused = true

func unpause():
	paused = false


func _on_EnemyBullet_area_entered(_area):
	queue_free()
