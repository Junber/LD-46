extends PopupPanel

signal ok_button_pressed()
signal abort_button_pressed()

@onready var titleLabel = $VBoxContainer/Label
@onready var textLabel = $VBoxContainer/MarginContainer/MessageLabel
@onready var okButton = $VBoxContainer/ButtonMarginContainer/HBoxContainer/OkButton
@onready var abortButton = $VBoxContainer/ButtonMarginContainer/HBoxContainer/AbortButton
@onready var timer = $Timer

func _ready():
	abortButton.visible = false

func set_custom_title(custom_title: String):
	titleLabel.text = custom_title

func set_text(text: String):
	textLabel.text = text

func hide_after_sec(seconds):
	timer.start(seconds)

func hide_ok_button():
	okButton.visible = false

func hide_abort_button():
	abortButton.visible = false

func show_ok_button():
	okButton.visible = true

func show_abort_button():
	abortButton.visible = true

func _on_Timer_timeout():
	hide()

func _on_OkButton_pressed():
	hide()
	emit_signal("ok_button_pressed")

func _on_AbortButton_pressed():
	hide()
	emit_signal("abort_button_pressed")
