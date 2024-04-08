extends TextureRect

signal backButton_pressed()
signal button_pressed()

@export var optionsFileName = "user://Options.save" # (String, FILE)

var resolutions = [
	Vector2i(960, 540),
	Vector2i(1200, 675),
	Vector2i(1440, 810),
	Vector2i(1920, 1080),
	Vector2i(3840, 2160)
]
@onready var resolutionButton = $VBoxContainer/SettingsContainer/GridContainer/ResolutionButton
@onready var fullscreenToggle = $VBoxContainer/SettingsContainer/GridContainer/FullscreenToggle
@onready var musicSlider = $VBoxContainer/SettingsContainer/GridContainer/MusicSlider
@onready var sfxSlider = $VBoxContainer/SettingsContainer/GridContainer/SoundeffectsSlider

@onready var start_resolution = get_node("/root/Main").start_resolution
var should_be_fullscreen := true

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	if OS.get_name() == "HTML5":
		resolutionButton.disabled = true
	set_resolution_options()
	initialze_setting()
	load_options()

func initialze_setting():
	if OS.get_name() != "HTML5":
		resolutionButton.select(start_resolution)
		get_window().set_size(resolutions[start_resolution])
	set_volume("Music", 100)
	set_volume("SoundEffects", 100)

func set_resolution_button_to_current_resolution():
	var resolutionIndex = resolutions.find(get_window().get_size())
	if resolutionIndex == -1:
		resolutions.append(get_window().get_size())
		set_resolution_options()
		resolutionIndex = resolutions.size()-1

	resolutionButton.select(resolutionIndex)

func popup():
	visible = true
	get_tree().paused = true

	musicSlider.set_value(get_volume("Music"))
	sfxSlider.set_value(get_volume("SoundEffects"))
	fullscreenToggle.set_pressed(((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN)))
	set_resolution_button_to_current_resolution()

func go_away():
	visible = false
	save_options()

func set_resolution_options():
	resolutionButton.clear()
	for resolutionIndex in range(resolutions.size()):
		var resolution_text = str(resolutions[resolutionIndex].x) + " x " + str(resolutions[resolutionIndex].y)
		resolutionButton.add_item(resolution_text, resolutionIndex)

func set_volume(busName, newVolume):
	var busIndex = AudioServer.get_bus_index(busName)
	if newVolume == 0:
		AudioServer.set_bus_mute(busIndex, true)
	else:
		AudioServer.set_bus_mute(busIndex, false)
		AudioServer.set_bus_volume_db(busIndex, linear_to_db(newVolume/100))

func get_volume(busName):
	var busIndex = AudioServer.get_bus_index(busName)
	if AudioServer.is_bus_mute(busIndex):
		return 0
	else:
		var volumeDb = AudioServer.get_bus_volume_db(busIndex)
		return 100 * db_to_linear(volumeDb)

func save_options():
	var optionsData = {
		"fullscreen" : ((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN)),
		"resolution_x" : get_window().get_size().x,
		"resolution_y" : get_window().get_size().y,
		"music_volume" : get_volume("Music"),
		"sfx_volume" : get_volume("SoundEffects")
	}

	var saveFile = FileAccess.open(optionsFileName, FileAccess.WRITE)
	saveFile.store_line(JSON.stringify(optionsData))
	saveFile.close()

func load_options():
	var saveFile = FileAccess.open(optionsFileName, FileAccess.READ)
	if not saveFile:
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (true) else Window.MODE_WINDOWED
		return

	var test_json_conv = JSON.new()
	test_json_conv.parse(saveFile.get_line())
	var optionsData = test_json_conv.get_data()

	if optionsData.has("fullscreen"):
		should_be_fullscreen = optionsData["fullscreen"]
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (optionsData["fullscreen"]) else Window.MODE_WINDOWED
	else:
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (true) else Window.MODE_WINDOWED
	if OS.get_name() != "HTML5" and optionsData.has("resolution_x") and optionsData.has("resolution_y"):
		var window_size = Vector2(optionsData["resolution_x"], optionsData["resolution_y"])
		get_window().set_size(window_size)
	if optionsData.has("music_volume"):
		set_volume("Music", optionsData["music_volume"])
	if optionsData.has("sfx_volume"):
		set_volume("SoundEffects", optionsData["sfx_volume"])

func _on_BackButton_pressed():
	emit_signal("backButton_pressed")
	emit_signal("button_pressed")

func _on_FullscreenToggle_toggled(is_button_pressed):
	should_be_fullscreen = is_button_pressed
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (is_button_pressed) else Window.MODE_WINDOWED
	emit_signal("button_pressed")

	if OS.get_name() != "HTML5":
		resolutionButton.set_disabled(is_button_pressed)
	set_resolution_button_to_current_resolution()

func _on_ResolutionButton_item_selected(id):
	get_window().set_size(resolutions[id])
	emit_signal("button_pressed")

func _on_MusicSlider_value_changed(value):
	set_volume("Music", value)

func _on_SoundeffectsSlider_value_changed(value):
	set_volume("SoundEffects", value)

func _input(event):
	if OS.get_name() == "HTML5":
		if event.has_method("is_pressed") and !event.is_pressed():
			return
		if event is InputEventKey and event.scan_code in [KEY_CTRL, KEY_SHIFT, KEY_ALT]:
			return
		if should_be_fullscreen and !((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN)):
			get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (true) else Window.MODE_WINDOWED
