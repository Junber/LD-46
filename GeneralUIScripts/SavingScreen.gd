extends TextureRect

signal backButton_pressed()
signal save(fileName)
signal button_pressed()

@onready var savesList = $VBoxContainer/ListContainer/ItemList
const Util = preload("res://SaveFileUtils.gd")

@onready var popupPanel = $PopupPanel
@onready var lineEdit = $VBoxContainer/MarginContainer/LineEdit

func _ready():
	visible = false

func popup():
	visible = true
	Util.update_saves_list(savesList)

func go_away():
	visible = false

func popup_saved_game():
	popupPanel.set_custom_title("Saved!")
	popupPanel.set_text("Your current progress was saved.\nYou can now savely quit the game without losing your progress.")
	popupPanel.hide_abort_button()
	popupPanel.hide_after_sec(2)
	popupPanel.popup_centered()

func popup_illegal_name():
	popupPanel.set_custom_title("Illegal Name")
	popupPanel.set_text("The name you entered is not a valid file name.\nFile names are not allowed to contain any of:\n: / \\ ? * \" | % < >")
	popupPanel.show_ok_button()
	popupPanel.popup_centered()

func popup_overwrite_warning():
	popupPanel.set_custom_title("Overwrite?")
	popupPanel.set_text("If you proceed you'll overwrite this save.\nAre you really sure?")
	popupPanel.show_ok_button()
	popupPanel.show_abort_button()
	popupPanel.connect("ok_button_pressed", ok_overwrite)
	popupPanel.connect("abort_button_pressed", abort_overwrite)
	popupPanel.popup_centered()

func ok_overwrite():
	popupPanel.disconnect("ok_button_pressed", ok_overwrite)
	popupPanel.disconnect("abort_button_pressed", abort_overwrite)
	save_unchecked()

func abort_overwrite():
	popupPanel.disconnect("abort_button_pressed", abort_overwrite)
	popupPanel.disconnect("ok_button_pressed", ok_overwrite)

func save_unchecked():
	emit_signal("save", lineEdit.text)
	popup_saved_game()
	Util.update_saves_list(savesList)

func save_checked():
	if not lineEdit.text.is_valid_filename():
		popup_illegal_name()
		return
	elif FileAccess.file_exists("user://saves/" + lineEdit.text + ".save"):
		popup_overwrite_warning()
		return

	save_unchecked()

func change_save_name(newName):
	lineEdit.text = newName

func _on_BackButton_pressed():
	emit_signal("backButton_pressed")
	emit_signal("button_pressed")

func _on_LineEdit_text_entered(_newText):
	save_checked()
	emit_signal("button_pressed")

func _on_ItemList_item_selected(index):
	lineEdit.text = $VBoxContainer/ListContainer/ItemList.get_item_text(index)

func _on_SaveButton_pressed():
	save_checked()
	emit_signal("button_pressed")


func _on_ItemList_item_activated(_index):
	save_checked()
	emit_signal("button_pressed")
