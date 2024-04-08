extends TextureRect

signal QuitButton_pressed()
signal RestartButton_pressed()
signal OptionsButton_pressed()
signal ContinueButton_pressed()
signal SaveButton_pressed()
signal LoadButton_pressed()
signal DeleteButton_pressed()
signal button_pressed()


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	if OS.get_name() == "HTML5":
		$MarginContainer/VBoxContainer/QuitButton.disabled = true

func popup():
	visible = true

func go_away():
	visible = false

func _on_QuitButton_pressed():
	emit_signal("button_pressed")
	emit_signal("QuitButton_pressed")

func _on_RestartButton_pressed():
	emit_signal("RestartButton_pressed")
	emit_signal("button_pressed")

func _on_OptionsButton_pressed():
	emit_signal("OptionsButton_pressed")
	emit_signal("button_pressed")

func _on_ContinueButton_pressed():
	emit_signal("ContinueButton_pressed")
	emit_signal("button_pressed")

func _on_SaveButton_pressed():
	emit_signal("SaveButton_pressed")
	emit_signal("button_pressed")

func _on_LoadButton_pressed():
	emit_signal("LoadButton_pressed")
	emit_signal("button_pressed")

func _on_DeleteButton_pressed():
	emit_signal("DeleteButton_pressed")
	emit_signal("button_pressed")
