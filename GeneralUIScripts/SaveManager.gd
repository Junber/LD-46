extends Node

signal loading_error(message)

@export var currentSaveVersion: int

func _ready():
	pass


func save_object(object):
	var savedData = {
		"filename" : object.get_scene_file_path()
	}

	for propertyName in object.savedProperties():
		savedData[propertyName] = object.get(propertyName)

	return savedData

func save_game(fileName):
	var saveFile = FileAccess.open("user://saves/" + fileName + ".save", FileAccess.WRITE)
	saveFile.store_line(str(currentSaveVersion))
	var saveNodes = get_tree().get_nodes_in_group("Persistent")
	for node in saveNodes:
		var nodeData = save_object(node)
		saveFile.store_line(JSON.stringify(nodeData))
	saveFile.close()


func load_object(object, data):
	for propertyName in data:
		if propertyName != "filename":
			object.set(propertyName, data[propertyName])

func load_game(fileName) -> bool:
	var saveFile = FileAccess.open("user://saves/" + fileName + ".save", FileAccess.READ)
	if not saveFile:
		emit_signal("loading_error", "File not found!")
		return false

	var savedSaveVersion = int(saveFile.get_line())
	if savedSaveVersion != currentSaveVersion:
		emit_signal("loading_error", "Unfortunately, this version of the game is no longer compatible with the version of the save file. Thus it could not be loaded.")
		return false

	while not saveFile.eof_reached():
		var currentLine = saveFile.get_line()
		if currentLine.length() > 0:
			var test_json_conv = JSON.new()
			test_json_conv.parse(currentLine)
			var currentData = test_json_conv.get_data()

			var saveNodes = get_tree().get_nodes_in_group("Persistent")
			for node in saveNodes:
				if node.get_scene_file_path() == currentData["filename"]:
					load_object(node, currentData)

	saveFile.close()

	return true


func delete_save(fileName):
	DirAccess.open("user://saves/").remove(fileName + ".save")
