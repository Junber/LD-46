extends TextureRect

signal backButton_pressed()
signal deleteButton_pressed(fileName)
signal button_pressed()

@onready var popupPanel = $PopupPanel

@onready var savesList = $VBoxContainer/ListContainer/ItemList
const Util = preload("res://SaveFileUtils.gd")

func _ready():
	visible = false

func popup():
	visible = true
	Util.update_saves_list(savesList)

func go_away():
	visible = false

func send_delete(index):
	var fileName = savesList.get_item_text(index)
	emit_signal("deleteButton_pressed", fileName)
	emit_signal("button_pressed")
	Util.update_saves_list(savesList)

func popup_delete_warning(index):
	popupPanel.set_custom_title("Overwrite?")
	popupPanel.set_text("If you proceed you'll delete this save.\nAre you really sure?")
	popupPanel.show_ok_button()
	popupPanel.show_abort_button()
	popupPanel.connect("ok_button_pressed", Callable(self, "ok_overwrite").bind(index))
	popupPanel.connect("abort_button_pressed", Callable(self, "abort_overwrite"))
	popupPanel.popup()

func ok_overwrite(index):
	popupPanel.disconnect("ok_button_pressed", Callable(self, "ok_overwrite"))
	popupPanel.disconnect("abort_button_pressed", Callable(self, "abort_overwrite"))
	send_delete(index)

func abort_overwrite():
	popupPanel.disconnect("abort_button_pressed", Callable(self, "abort_overwrite"))
	popupPanel.disconnect("ok_button_pressed", Callable(self, "ok_overwrite"))


func _on_BackButton_pressed():
	emit_signal("backButton_pressed")
	emit_signal("button_pressed")


func _on_ItemList_item_activated(index):
	popup_delete_warning(index)


func _on_LoadButton_pressed():
	popup_delete_warning(savesList.get_selected_items()[0])
