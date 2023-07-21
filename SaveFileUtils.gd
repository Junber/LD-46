static func update_saves_list(savesList: ItemList):
	savesList.clear()
	
	var dir = Directory.new()
	if not dir.dir_exists("user://saves/"):
		dir.make_dir("user://saves/")
		
	if dir.open("user://saves/") == OK:
		dir.list_dir_begin()
		var fileName = dir.get_next()
		while fileName != "":
			if not dir.current_is_dir():
				savesList.add_item(fileName.left(fileName.length() - 5))
				savesList.set_item_tooltip_enabled(savesList.get_item_count() - 1, false)
			fileName = dir.get_next()
		savesList.sort_items_by_text()
	else:
		print("An error occurred when trying to access the path.")
