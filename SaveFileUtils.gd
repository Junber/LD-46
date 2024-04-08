static func update_saves_list(savesList: ItemList):
	savesList.clear()

	if not DirAccess.dir_exists_absolute("user://saves/"):
		DirAccess.make_dir_absolute("user://saves/")

	var dir = DirAccess.open("user://saves/")
	if dir:
		for fileName in dir.get_files():
			savesList.add_item(fileName.left(fileName.length() - 5))
			savesList.set_item_tooltip_enabled(savesList.get_item_count() - 1, false)
		savesList.sort_items_by_text()
	else:
		print("An error occurred when trying to access the path.")
