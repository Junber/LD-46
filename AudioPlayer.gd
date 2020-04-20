extends AudioStreamPlayer

var introDict = {
	"deep sea" : preload("res://Resources/Music/deep_sea_intro.ogg")
}

var loopDict = {
	"deep sea" : preload("res://Resources/Music/deep_sea_loop.ogg"),
	"deep sea creepy" : preload("res://Resources/Music/deep_sea_creepy_loop.ogg"),
	"everyday" : preload("res://Resources/Music/deep_sea_loop.ogg") #TODO
}

var currentLoop

export(String) var initialMusic = "deep sea"


# Called when the node enters the scene tree for the first time.
func _ready():
	play_music(initialMusic)


func play_music(name: String):
	currentLoop = loopDict[name]
	stop()
	if introDict.has(name):
		set_stream(introDict[name])
	else:
		set_stream(loopDict[name])
	play()
	
func _on_AudioPlayer_finished():
	set_stream(currentLoop)
	play()


func _on_DialogManager_play_music(name):
	play_music(name)
