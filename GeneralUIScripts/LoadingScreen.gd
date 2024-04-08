extends TextureRect

signal backButton_pressed()
signal loadButton_pressed(fileName)
signal button_pressed()

@onready var savesList = $VBoxContainer/ListContainer/ItemList
@onready var popupPanel = $PopupPanel
const Util = preload("res://SaveFileUtils.gd")

func _ready():
	visible = false

func popup():
	visible = true
	Util.update_saves_list(savesList)

func go_away():
	visible = false

func send_load(index):
	var fileName = savesList.get_item_text(index)
	emit_signal("loadButton_pressed", fileName)
	emit_signal("button_pressed")

func popup_error(message):
	popupPanel.set_custom_title("Error when loading this save!")
	popupPanel.set_text(message)
	popupPanel.hide_abort_button()
	popupPanel.popup()


func _on_BackButton_pressed():
	emit_signal("backButton_pressed")
	emit_signal("button_pressed")

func _on_ItemList_item_activated(index):
	send_load(index)

func _on_LoadButton_pressed():
	send_load(savesList.get_selected_items()[0])

func _on_SaveManager_loading_error(message):
	popup_error(message)
