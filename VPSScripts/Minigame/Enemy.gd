extends Area2D

signal death()

var paused: bool = false
var speed: float = 2.0
var bulletSpeed: float = 15.0

var real_position: float

export(PackedScene) var bulletScene = preload("res://VPSScenes/Minigame/EnemyBullet.tscn")
onready var bulletTimer = $BulletTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	real_position = position.y
	pass

func _process(delta):
	if not paused:
		real_position -= delta * speed
		position.y = round(real_position)

func set_speed(newSpeed):
	speed = newSpeed

func set_bullet_speed(newSpeed):
	bulletSpeed = newSpeed

func set_bullet_time(newTime):
	bulletTimer.set_wait_time(newTime)
	bulletTimer.start()

func pause():
	paused = true
	bulletTimer.set_paused(true)

func unpause():
	paused = false
	bulletTimer.set_paused(false)

func shoot():
	var bullet = bulletScene.instance()
	bullet.position = position
	get_parent().add_child(bullet)
	bullet.set_velocity(Vector2(0, -bulletSpeed))


# warning-ignore:unused_argument
func _on_Area2D_area_entered(area):
	emit_signal("death")
	queue_free()


func _on_BulletTimer_timeout():
	shoot()
