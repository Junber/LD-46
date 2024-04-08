extends Node2D
signal new_chapter(number, subtitle)

@export var start_resolution: int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	show_screen($StartScreen)

func game_over():
	show_screen($GameOverScreen)

func show_new_chapter(number, subtitle):
	emit_signal("new_chapter", number, subtitle)
	show_screen($ChapterScreen)

func show_screen(screen):
	get_tree().paused = true
	screen.popup()

func hide_screen(screen):
	get_tree().paused = false
	screen.go_away()

func restart_game():
	get_tree().paused = false
	get_tree().reload_current_scene()

func quit_game():
	get_tree().quit()

func continue_game():
	hide_screen($MenuScreen)

func _input(event):
	if event.is_action_pressed("menu"):
		show_screen($MenuScreen)

func _on_Tamagotchi_tamagotchi_died():
	game_over()

func _on_GameOverScreen_QuitButton_pressed():
	quit_game()

func _on_GameOverScreen_RestartButton_pressed():
	restart_game()

func _on_MenuScreen_QuitButton_pressed():
	quit_game()

func _on_MenuScreen_RestartButton_pressed():
	restart_game()

func _on_MenuScreen_OptionsButton_pressed():
	show_screen($OptionsScreen)

func _on_MenuScreen_ContinueButton_pressed():
	continue_game()

func _on_OptionsScreen_backButton_pressed():
	$OptionsScreen.go_away()

func _on_DialogManager_new_chapter(number, subtitle):
	show_new_chapter(number, subtitle)

func _on_ChapterScreen_hide_screen():
	hide_screen($ChapterScreen)

func _on_DialogManager_game_ended():
	show_screen($EndScreen)

func _on_EndScreen_hide_screen():
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
	get_tree().paused = false

func _on_StartScreen_hide_screen():
	hide_screen($StartScreen)
	show_screen($StartMenuScreen)

func _on_StartMenuScreen_StartButton_pressed():
	hide_screen($StartMenuScreen)
	$DialogManager.start_dialog()

func _on_ChapterScreen_pause_music():
	$MusicPlayer.set_stream_paused(true)

func _on_ChapterScreen_unpause_music():
	$MusicPlayer.set_stream_paused(false)
	$MusicPlayer.play()


func _on_StartMenuScreen_LoadButton_pressed():
	show_screen($LoadingScreen)

func _on_LoadingScreen_backButton_pressed():
	$LoadingScreen.go_away()

func _on_LoadingScreen_loadButton_pressed(fileName):
	if $SaveManager.load_game(fileName):
		hide_screen($LoadingScreen)
		hide_screen($StartMenuScreen)
		hide_screen($MenuScreen)
		$DialogManager.print_current_dialog_line()

func _on_MenuScreen_SaveButton_pressed():
	show_screen($SavingScreen)

func _on_MenuScreen_LoadButton_pressed():
	show_screen($LoadingScreen)

func _on_SaveDeletingScreen_deleteButton_pressed(fileName):
	$SaveManager.delete_save(fileName)

func _on_SaveDeletingScreen_backButton_pressed():
	$SaveDeletingScreen.go_away()

func _on_StartMenuScreen_DeleteButton_pressed():
	show_screen($SaveDeletingScreen)

func _on_MenuScreen_DeleteButton_pressed():
	show_screen($SaveDeletingScreen)

func _on_saving_screen_back_button_pressed() -> void:
	$SavingScreen.go_away()

func _on_saving_screen_save(fileName: Variant) -> void:
	$SaveManager.save_game(fileName)
