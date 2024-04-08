extends Node2D

signal start_talking
signal end_talking
signal all_text_appeared

@onready var label = $TextBox/Label
@onready var timer = $ShowTextTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	show_all_text()

func set_text(text):
	label.text = text
	label.set_visible_characters(0)
	timer.start()
	emit_signal("start_talking")

func has_all_text_appeared():
	return label.get_visible_characters() >= label.get_total_character_count()

func show_all_text():
	label.set_visible_characters(label.get_total_character_count())
	timer.stop()
	emit_signal("all_text_appeared")
	emit_signal("end_talking")

func _on_ShowTextTimer_timeout():
	label.set_visible_characters(label.get_visible_characters() + 1)
	if not has_all_text_appeared():
		timer.start()
	else:
		emit_signal("all_text_appeared")
		emit_signal("end_talking")

