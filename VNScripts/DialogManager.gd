extends Node

# warning-ignore:unused_signal
signal reduce_fullness(amount)
# warning-ignore:unused_signal
signal reduce_awakeness(amount)
# warning-ignore:unused_signal
signal reduce_fun(amount)
# warning-ignore:unused_signal
signal reduce_happiness(amount)
# warning-ignore:unused_signal
signal reduce_everything(amount)

signal play_music(name)
signal play_sound_effect(name)
signal button_pressed()

signal change_characters(characters)
signal change_background(background)

signal start_talking(name)
signal end_talking()

signal turn_tamagotchi_on()
signal turn_tamagotchi_off()
signal change_squid_stage(newStageName)

signal new_chapter(number, subtitle)

signal advance_dialog()
signal game_ended()

@export_file var startFileName

var choiceButtonScene = preload("res://VNScenes/ChoiceButton.tscn")
@onready var vnTextBox = get_node("/root/Main/VNTextBox")
@onready var tamagotchiTextBox = get_node("/root/Main/TamagotchiTextBox")
@onready var choiceButtonContainer = get_node("/root/Main/CharacterView/ChoiceButtonContainer")

var data
var dataPosition
var dialogChoices
var maxDataPosition
var beforeChoice : bool = false
var inChoice : bool = false
var requireEating : bool = false

var currentChapter : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	load_file(startFileName)

func _unhandled_input(event):
	if event.is_action_pressed("choice_1"):
		pick_choice(0)
	elif event.is_action_pressed("choice_2"):
		pick_choice(1)
	elif event.is_action_pressed("choice_3"):
		pick_choice(2)
	elif event.is_action_pressed("advance") or \
	  event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not vnTextBox.has_all_text_appeared():
			vnTextBox.show_all_text()
		elif not tamagotchiTextBox.has_all_text_appeared():
			tamagotchiTextBox.show_all_text()
		elif not inChoice and not beforeChoice and not requireEating:
			print_next_dialog_line()

func savedProperties():
	return ["dataPosition",
		"dialogChoices",
		"maxDataPosition",
		"beforeChoice",
		"inChoice",
		"requireEating",
		"currentChapter"]


func start_dialog():
	execute_advance_side_effects(get_current_dialog_data())
	print_current_dialog_line()

func load_file(fileName):
	var data_file = FileAccess.open(fileName, FileAccess.READ)
	if not data_file:
		print("File could not be read.")
		return
	var data_text = data_file.get_as_text()
	data_file.close()
	var test_json_conv := JSON.new()
	if test_json_conv.parse(data_text) != OK:
		print("File could not be parsed as JSON.")
		print("Line ", test_json_conv.get_error_line(), ": ", test_json_conv.get_error_message())
		return

	var data_parse = test_json_conv.get_data()
	data = {"next" : data_parse}
	dataPosition = [0]
	dialogChoices = []
	maxDataPosition = [data["next"].size()]


func get_current_dialog_data():
	var currentData = data
	for i in range(dataPosition.size()):
		currentData = currentData["next"][dataPosition[i]]
		if i < dataPosition.size() - 1:
			currentData = currentData["choices"][dialogChoices[i]]
	return currentData


func print_next_dialog_line():
	go_to_next_line()
	print_current_dialog_line()

func go_to_next_line():
	while dataPosition.size() > 0 and dataPosition[dataPosition.size() - 1] + 1 >= maxDataPosition[dataPosition.size() - 1]:
		dataPosition.pop_back()
		maxDataPosition.pop_back()
		dialogChoices.pop_back()

	if dataPosition.size() > 0:
		dataPosition[dataPosition.size() - 1] += 1

	emit_signal("advance_dialog")
	execute_advance_side_effects(get_current_dialog_data())

func print_current_dialog_line():
	if dataPosition.size() == 0:
		emit_signal("game_ended")
		return

	for child in choiceButtonContainer.get_children():
		child.queue_free()

	var currentData = get_current_dialog_data()

	execute_print_side_effects(currentData)

	if currentData.has("name") and currentData["name"] == "Squid":
		tamagotchiTextBox.set_text(currentData["text"])
	else:
		vnTextBox.set_text(currentData["text"])

	if currentData.has("choices"):
		beforeChoice = true

	if currentData["text"].length() == 0:
		print_next_dialog_line()

func execute_advance_side_effects(currentData):
	if currentData.has("new_chapter"):
		emit_signal("new_chapter", currentChapter, currentData["new_chapter"])
		currentChapter += 1

	for need in ["reduce_fullness", "reduce_awakeness", "reduce_fun", "reduce_happiness", "reduce_everything"]:
		if currentData.has(need):
			emit_signal(need, currentData[need])


func execute_print_side_effects(currentData):
	if currentData.has("music"):
		emit_signal("play_music", currentData["music"])

	if currentData.has("sfx"):
		emit_signal("play_sound_effect", currentData["sfx"])

	if currentData.has("characters"):
		emit_signal("change_characters", currentData["characters"])

	if currentData.has("background"):
		emit_signal("change_background", currentData["background"])

	if currentData.has("tamagotchi_on"):
		if currentData["tamagotchi_on"]:
			emit_signal("turn_tamagotchi_on")
		else:
			emit_signal("turn_tamagotchi_off")

	if currentData.has("squid_stage"):
		emit_signal("change_squid_stage", currentData["squid_stage"])

	if currentData.has("requireEating"):
		requireEating = true

	if currentData.has("name") and currentData["name"] != "Squid":
		vnTextBox.set_character_name(currentData["name"])

	if not currentData.has("name") or currentData["name"] != "Squid":
		if currentData.has("talking_name"):
			emit_signal("start_talking", currentData["talking_name"])
		elif currentData.has("name"):
			if currentData["name"].length() != 0:
				emit_signal("start_talking", currentData["name"])
		else:
			emit_signal("start_talking", "")

func spawn_choice_buttons():
	beforeChoice = false
	inChoice = true
	var currentData = get_current_dialog_data()
	for i in range(currentData["choices"].size()):
		var button = choiceButtonScene.instantiate()
		button.set_label(currentData["choices"][i]["text"])
		button.connect("pressed", Callable(self, "_on_ChoiceButtonPressed").bind(i))
		choiceButtonContainer.add_child(button)

func pick_choice(choice):
	if inChoice:
		var currentData = get_current_dialog_data()

		dialogChoices.push_back(choice)
		dataPosition.push_back(0)
		maxDataPosition.push_back(currentData["choices"][choice]["next"].size())

		inChoice = false
		emit_signal("button_pressed")

		print_current_dialog_line()


func _on_ChoiceButtonPressed(choice):
	pick_choice(choice)


func _on_VNTextBox_all_text_appeared():
	if beforeChoice:
		spawn_choice_buttons()
	emit_signal("end_talking")


func _on_Tamagotchi_eat():
	if requireEating and vnTextBox.has_all_text_appeared() and tamagotchiTextBox.has_all_text_appeared():
		requireEating = false
		print_next_dialog_line()


func _on_TamagotchiTextBox_all_text_appeared():
	if beforeChoice:
		spawn_choice_buttons()
