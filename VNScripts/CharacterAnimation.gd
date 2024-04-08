extends Node2D

@export var minFrameTime := 0.02
@export var maxFrameTime := 0.2

@onready var sprite = $Sprite2D
@onready var timer = $NextFrameTimer

func set_sprite_frames(spriteFrames):
	sprite.set_sprite_frames(spriteFrames)

func start_animating():
	timer.set_wait_time(randf_range(minFrameTime, maxFrameTime))
	timer.start()

func stop_animating():
	timer.stop()
	sprite.set_frame(0)


func _on_NextFrameTimer_timeout():
	timer.set_wait_time(randf_range(minFrameTime, maxFrameTime))
	sprite.set_frame(1 - sprite.get_frame())
