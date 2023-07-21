extends Area2D

var paused: bool = false

var real_position: float

func _ready():
	real_position = position.y


func _process(delta):
	if not paused:
		real_position += delta * 70
		position.y = round(real_position)

func pause():
	paused = true

func unpause():
	paused = false
