extends "res://VPSScripts/Minigame/EnemyBullet.gd"

var bulletScene = preload("res://VPSScenes/Minigame/EnemyBullet.tscn")

@onready var bulletTimer = $MoreBulletsTimer

func pause():
	super.pause()
	bulletTimer.set_paused(true)

func unpause():
	super.unpause()
	bulletTimer.set_paused(false)

func set_velocity(newVelocity):
	super.set_velocity(newVelocity)
	bulletTimer.set_wait_time(30 / newVelocity.length())
	bulletTimer.start()

func _on_MoreBulletsTimer_timeout():
	for i in range(5):
		var bullet = bulletScene.instantiate()
		bullet.position = position
		bullet.velocity = velocity.rotated((i * 2 + 1) * 2 * PI / 10)
		get_parent().add_child(bullet)
