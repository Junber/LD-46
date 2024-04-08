extends Node2D

var currentCharacters = {}
var talkingCharacterName : String = "lucas"

var characterScene = preload("res://VNScenes/CharacterAnimation.tscn")

var characterMap = {
	"christine": preload("res://Resources/Animations/Characters/Christine/Christine.tres"),
	"christine happy": preload("res://Resources/Animations/Characters/Christine/ChristineHappy.tres"),
	"christine sad": preload("res://Resources/Animations/Characters/Christine/ChristineSad.tres"),
	"christine surprised": preload("res://Resources/Animations/Characters/Christine/ChristineSurprised.tres"),

	"michael": preload("res://Resources/Animations/Characters/Michael/Michael.tres"),
	"michael happy": preload("res://Resources/Animations/Characters/Michael/MichaelHappy.tres"),
	"michael sad": preload("res://Resources/Animations/Characters/Michael/MichaelSad.tres"),
	"michael surprised": preload("res://Resources/Animations/Characters/Michael/MichaelSurprised.tres"),

	"michael old": preload("res://Resources/Animations/Characters/MichaelOld/MichaelOld.tres"),
	"michael old happy": preload("res://Resources/Animations/Characters/MichaelOld/MichaelOldHappy.tres"),
	"michael old sad": preload("res://Resources/Animations/Characters/MichaelOld/MichaelOldSad.tres"),
	"michael old surprised": preload("res://Resources/Animations/Characters/MichaelOld/MichaelOldSurprised.tres"),

	"sarah": preload("res://Resources/Animations/Characters/Sarah/Sarah.tres"),
	"sarah happy": preload("res://Resources/Animations/Characters/Sarah/SarahHappy.tres"),
	"sarah sad": preload("res://Resources/Animations/Characters/Sarah/SarahSad.tres"),
	"sarah surprised": preload("res://Resources/Animations/Characters/Sarah/SarahSurprised.tres"),

	"sarah old": preload("res://Resources/Animations/Characters/SarahOld/SarahOld.tres"),
	"sarah old happy": preload("res://Resources/Animations/Characters/SarahOld/SarahOldHappy.tres"),
	"sarah old sad": preload("res://Resources/Animations/Characters/SarahOld/SarahOldSad.tres"),
	"sarah old surprised": preload("res://Resources/Animations/Characters/SarahOld/SarahOldSurprised.tres"),
}

@onready var positions = [
	[
		#positions[0][0]
		$"1CharacterPosition1".position
	],
	[
		#positions[1][0]
		$"2CharacterPosition1".position,
		#positions[1][1]
		$"2CharacterPosition2".position,
	]
]

@onready var backgroundMap = {
	"beach": $BackgroundBeach,
	"deep sea creatures": $BackgroundDeepSeaCreatures,
	"living room night": $BackgroundLivingRoomNight,
	"black": $Black,
	"city": $BackgroundCity,
	"class": $BackgroundClass,
	"deep sea": $BackgroundDeepSea,
	"deep sea eye": $BackgroundDeepSeaEye,
	"living room": $BackgroundLivingRoom,
	"office": $BackgroundOffice,
	"shallow sea": $BackgroundShallowSea,
	"shallow sea creatures": $BackgroundShallowSeaCreatures,
}

@onready var foremostBackground = $BackgroundShallowSeaCreatures

@export var startingBackground := "field"

# Used only for saving/loading purposes
var currentCharacterNames : get = get_currentCharacterNames, set = set_currentCharacterNames
var backgroundName : get = get_backgroundName, set = set_backgroundName

func _ready():
	change_background(startingBackground)

func savedProperties():
	return ["currentCharacterNames",
		"backgroundName",
		"talkingCharacterName"]

func get_currentCharacterNames():
	currentCharacterNames = []
	for characterName in currentCharacters:
		currentCharacterNames.append(characterName)
	return currentCharacterNames

func set_currentCharacterNames(newCharacterNames):
	remove_characters()
	add_characters(newCharacterNames)

func get_backgroundName():
	for potentialBackgroundName in backgroundMap:
		if backgroundMap[potentialBackgroundName].visible:
			return potentialBackgroundName
	return "black"

func set_backgroundName(newBackgroundName):
	change_background(newBackgroundName)

func add_characters(listOfCharacters):
	#TODO: Remove if we get lucas sprites
	for character in listOfCharacters:
		if character.begins_with("lucas"):
			listOfCharacters.erase(character)
			break

	for index in range(listOfCharacters.size()):
		var character = add_character(listOfCharacters[index], positions[listOfCharacters.size() - 1][index])
		if index % 2 == 1:
			flip_character(character)

func turn_off_backgrounds():
	for background in backgroundMap:
		backgroundMap[background].visible = false

func change_background(newBackground: String):
	turn_off_backgrounds()
	backgroundMap[newBackground].visible = true

func flip_character(character):
	character.get_node("Sprite2D").flip_h = true

func add_character(characterName: String, character_position):
	var newCharacter = characterScene.instantiate()
	newCharacter.position = character_position
	foremostBackground.add_sibling(newCharacter)
	newCharacter.set_sprite_frames(characterMap[characterName])
	currentCharacters[characterName] = newCharacter
	return newCharacter

func remove_characters():
	for characterName in currentCharacters:
		currentCharacters[characterName].queue_free()
	currentCharacters.clear()


func _on_DialogManager_change_background(background):
	change_background(background)


func _on_DialogManager_change_characters(characters):
	remove_characters()
	add_characters(characters)


func _on_DialogManager_end_talking():
	for characterName in currentCharacters:
		if characterName.begins_with(talkingCharacterName):
			currentCharacters[characterName].stop_animating()


func _on_DialogManager_start_talking(character_name):
	if character_name.length() != 0:
		talkingCharacterName = character_name.to_lower()
		if talkingCharacterName == "mom":
			talkingCharacterName = "christine"

	for characterName in currentCharacters:
		if characterName.begins_with(talkingCharacterName):
			currentCharacters[characterName].start_animating()
