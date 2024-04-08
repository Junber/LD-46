extends AudioStreamPlayer

var introDict = {
	"deep sea" : preload("res://Resources/Music/deep_sea_intro.ogg"),
	"everyday" : preload("res://Resources/Music/everyday_intro.ogg"),
	"sad" : preload("res://Resources/Music/sad_intro.ogg")
}

var loopDict = {
	"deep sea" : preload("res://Resources/Music/deep_sea_loop.ogg"),
	"deep sea creepy" : preload("res://Resources/Music/deep_sea_creepy_loop.ogg"),
	"everyday" : preload("res://Resources/Music/everyday_loop.ogg"),
	"sad" : preload("res://Resources/Music/sad_loop.ogg")
}

var currentLoop

@export var initialMusic: String = "deep sea"


# Called when the node enters the scene tree for the first time.
func _ready():
	play_music(initialMusic)


func play_music(track_name: String):
	if track_name.length() == 0:
		set_stream_paused(true)
	else:
		currentLoop = loopDict[track_name]
		stop()
		if introDict.has(track_name):
			set_stream(introDict[track_name])
		else:
			set_stream(loopDict[track_name])
		play()
		set_stream_paused(false)

func _on_AudioPlayer_finished():
	set_stream(currentLoop)
	play()


func _on_DialogManager_play_music(track_name):
	play_music(track_name)
