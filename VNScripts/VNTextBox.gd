extends Node2D

signal all_text_appeared

@onready var label := $TextBox/Label as RichTextLabel
@onready var nameLabel := $TextBox/NameLabel as RichTextLabel
@onready var timer := $ShowTextTimer as Timer

var textLengthUpperLimit = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	label.set_visible_characters(label.get_total_character_count())


func set_text(text: String):
	var italic := text.strip_edges().begins_with("[i]")

	label.add_theme_constant_override("outline_size", 50 if italic else 0)
	label.text = text
	label.set_visible_characters(0)
	timer.start()

	textLengthUpperLimit = text.length()

func set_character_name(character_name):
	if character_name.length() == 0:
		nameLabel.text = ""
	else:
		nameLabel.text = "[b]" + character_name + ":[/b]"


func text_length():
	if label.get_total_character_count() == 0: # the text length isn't ready yet
		return textLengthUpperLimit
	else:
		return label.get_total_character_count()


func has_all_text_appeared():
	return label.get_visible_characters() >= text_length()


func show_all_text():
	label.set_visible_characters(text_length())
	timer.stop()
	emit_signal("all_text_appeared")

func _on_ShowTextTimer_timeout():
	label.set_visible_characters(label.get_visible_characters() + 1)
	if not has_all_text_appeared():
		timer.start()
	else:
		emit_signal("all_text_appeared")
