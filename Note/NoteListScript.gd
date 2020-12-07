extends ItemList


func _ready():
	pass # Replace with function body.


#func _process(delta):
#	pass


func update_list():
	clear()
	for note in Global.note_list:
		if not note.deleted:
			if note.title:
				add_item(note.title)
			else:
				add_item(" ")


func _on_NoteList_item_rmb_selected(_index, _at_position):
	$NoteListPopupMenu.popup(Rect2(get_viewport().get_mouse_position(), Vector2(50, 50)))
	$NoteListPopupMenu.add_item("(copy?)")
	$NoteListPopupMenu.add_item("view")
	$NoteListPopupMenu.add_item("delete")


func _on_NoteListPopupMenu_popup_hide():
	$NoteListPopupMenu.clear()


func _on_NoteListPopupMenu_index_pressed(index):
	if index == 0:
		pass
	if index == 1:
		get_parent().view_note()
	if index == 2:
		get_parent().delete_note()
