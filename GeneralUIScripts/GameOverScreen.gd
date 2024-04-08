extends TextureRect

signal QuitButton_pressed()
signal RestartButton_pressed()
signal button_pressed()


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false

func popup():
	visible = true
	$Timer.start()

func show_buttons():
	$ButtonContainer.visible = true

func _on_QuitButton_pressed():
	emit_signal("QuitButton_pressed")
	emit_signal("button_pressed")

func _on_RestartButton_pressed():
	emit_signal("RestartButton_pressed")
	emit_signal("button_pressed")

func _on_Timer_timeout():
	show_buttons()

func _on_GameOverScreen_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		show_buttons()
