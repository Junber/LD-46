extends TextureRect

signal hide_screen

func _ready():
	pass

func _input(event):
	if visible and event.is_action_pressed("advance"):
		emit_signal("hide_screen")

func popup():
	visible = true

func go_away():
	visible = false

func _on_StartScreen_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("hide_screen")
