extends TextureRect

signal backButton_pressed()
signal button_pressed()

export(String, FILE) var optionsFileName = "user://Options.save"

var resolutions = [
	Vector2(960, 540),
	Vector2(1200, 675),
	Vector2(1440, 810),
	Vector2(1920, 1080),
	Vector2(3840, 2160)
]
onready var resolutionButton = $VBoxContainer/SettingsContainer/GridContainer/ResolutionButton
onready var fullscreenToggle = $VBoxContainer/SettingsContainer/GridContainer/FullscreenToggle
onready var musicSlider = $VBoxContainer/SettingsContainer/GridContainer/MusicSlider
onready var sfxSlider = $VBoxContainer/SettingsContainer/GridContainer/SoundeffectsSlider

onready var start_resolution = get_node("/root/Main").start_resolution
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
		OS.set_window_size(resolutions[start_resolution])
	set_volume("Music", 100)
	set_volume("SoundEffects", 100)

func set_resolution_button_to_current_resolution():
	var resolutionIndex = resolutions.find(OS.get_window_size())
	if resolutionIndex == -1:
		resolutions.append(OS.get_window_size())
		set_resolution_options()
		resolutionIndex = resolutions.size()-1
		
	resolutionButton.select(resolutionIndex)

func popup():
	visible = true
	get_tree().paused = true
	
	musicSlider.set_value(get_volume("Music"))
	sfxSlider.set_value(get_volume("SoundEffects"))
	fullscreenToggle.set_pressed(OS.is_window_fullscreen())
	set_resolution_button_to_current_resolution()

func go_away():
	visible = false
	save_options()

func set_resolution_options():
	resolutionButton.clear()
	for resolutionIndex in range(resolutions.size()):
		var resolution_text = String(resolutions[resolutionIndex].x) + " x " + String(resolutions[resolutionIndex].y)
		resolutionButton.add_item(resolution_text, resolutionIndex)

func set_volume(busName, newVolume):
	var busIndex = AudioServer.get_bus_index(busName)
	if newVolume == 0:
		AudioServer.set_bus_mute(busIndex, true)
	else:
		AudioServer.set_bus_mute(busIndex, false)
		AudioServer.set_bus_volume_db(busIndex, linear2db(newVolume/100))

func get_volume(busName):
	var busIndex = AudioServer.get_bus_index(busName)
	if AudioServer.is_bus_mute(busIndex):
		return 0
	else:
		var volumeDb = AudioServer.get_bus_volume_db(busIndex)
		return 100 * db2linear(volumeDb)

func save_options():
	var optionsData = {
		"fullscreen" : OS.is_window_fullscreen(),
		"resolution_x" : OS.get_window_size().x,
		"resolution_y" : OS.get_window_size().y,
		"music_volume" : get_volume("Music"),
		"sfx_volume" : get_volume("SoundEffects")
	}
	
	var saveFile = File.new()
	saveFile.open(optionsFileName, File.WRITE)
	saveFile.store_line(to_json(optionsData))
	saveFile.close()

func load_options():
	var saveFile = File.new()
	if not saveFile.file_exists(optionsFileName):
		OS.set_window_fullscreen(true)
		return

	saveFile.open(optionsFileName, File.READ)
	var optionsData = parse_json(saveFile.get_line())
	
	if optionsData.has("fullscreen"):
		should_be_fullscreen = optionsData["fullscreen"]
		OS.set_window_fullscreen(optionsData["fullscreen"])
	else:
		OS.set_window_fullscreen(true)
	if OS.get_name() != "HTML5" and optionsData.has("resolution_x") and optionsData.has("resolution_y"):
		var size = Vector2(optionsData["resolution_x"], optionsData["resolution_y"])
		OS.set_window_size(size)
	if optionsData.has("music_volume"):
		set_volume("Music", optionsData["music_volume"])
	if optionsData.has("sfx_volume"):
		set_volume("SoundEffects", optionsData["sfx_volume"])

func _on_BackButton_pressed():
	emit_signal("backButton_pressed")
	emit_signal("button_pressed")

func _on_FullscreenToggle_toggled(button_pressed):
	should_be_fullscreen = button_pressed
	OS.set_window_fullscreen(button_pressed)
	emit_signal("button_pressed")
	
	if OS.get_name() != "HTML5":
		resolutionButton.set_disabled(button_pressed)
	set_resolution_button_to_current_resolution()

func _on_ResolutionButton_item_selected(id):
	OS.set_window_size(resolutions[id])
	emit_signal("button_pressed")

func _on_MusicSlider_value_changed(value):
	set_volume("Music", value)

func _on_SoundeffectsSlider_value_changed(value):
	set_volume("SoundEffects", value)

func _input(event):
	if OS.get_name() == "HTML5":
		if event.has_method("is_pressed") and !event.is_pressed():
			return
		if event is InputEventKey and event.scan_code in [KEY_CONTROL, KEY_SHIFT, KEY_ALT]:
			return
		if should_be_fullscreen and !OS.window_fullscreen:
			OS.set_window_fullscreen(true)
