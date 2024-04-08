extends TextureRect

signal hide_screen()
signal button_pressed()

func _ready():
	pass

func _input(event):
	if visible and event.is_action_pressed("advance"):
		continue_if_possible()

func popup():
	visible = true
	$EatingSquid.visible = true
	$Credits.visible = false

func continue_if_possible():
	emit_signal("button_pressed")
	if $EatingSquid.visible:
		$EatingSquid.visible = false
		$Credits.visible = true
	else:
		emit_signal("hide_screen")

func _on_EndScreen_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		continue_if_possible()
