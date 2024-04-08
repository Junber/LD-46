extends Control

signal skip

@onready var timer = $Timer
var progress = 0

func _ready() -> void:
	progress_changed()

func progress_changed():
	var i = 1
	for circle in $HBoxContainer.get_children():
		if i <= progress:
			circle.modulate = Color(1.0, 1.0, 1.0, 0.8)
		else:
			circle.modulate = Color(1.0, 1.0, 1.0, 0.2)
		i += 1

func input():
	progress += 1
	progress_changed()
	if progress >= 3:
		skip.emit()
	timer.start()
	visible = true

func _process(_delta: float) -> void:
	if timer.time_left > timer.wait_time / 2.0:
		modulate = Color.WHITE
	else:
		modulate = Color.TRANSPARENT.lerp(Color.WHITE, timer.time_left / timer.wait_time)

func _on_timer_timeout() -> void:
	progress = 0
	progress_changed()
	visible = false
