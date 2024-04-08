extends TextureRect

signal hide_screen
signal pause_music
signal unpause_music

func _ready():
	visible = false

func _input(event):
	if visible and event.is_action_pressed("advance"):
		$Skip.input()

func popup():
	visible = true
	$ChapterLabel.visible = false
	$Subtitle.visible = false
	$TitleAppearTimer.start()
	$SubtitleAppearTimer.start()
	$AudioPlayer.play()
	emit_signal("pause_music")

func go_away():
	visible = false
	$AudioPlayer.stop()
	emit_signal("unpause_music")

func set_chapter(number):
	$ChapterLabel.text = "[center]Chapter " + str(number)

func set_chapter_subtitle(title):
	$Subtitle.text = "[center]" + title

func _on_Main_new_chapter(number, subtitle):
	set_chapter(number)
	set_chapter_subtitle(subtitle)

func _on_ChapterScreen_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		$Skip.input()

func _on_TitleAppearTimer_timeout():
	$ChapterLabel.visible = true

func _on_SubtitleAppearTimer_timeout():
	$Subtitle.visible = true


func _on_audio_player_finished() -> void:
	emit_signal("hide_screen")


func _on_skip_skip() -> void:
	emit_signal("hide_screen")
