extends Panel


func _ready():
	pass # Replace with function body.


#func _process(delta):
#	pass


func _on_ViewNoteButton_button_up():
	view_note()
	

func view_note():
	if not $NoteList.get_selected_items().empty():
		var note = Global.note_list[$NoteList.get_selected_items()[0]]
		if not note.in_scene:
			note.in_scene = true
			Global.notes_to_save.append(note)
			get_parent().add_child(note)
		else:
			pass
			#highlight and select note


func delete_note():
	print("deleting note")
	if not $NoteList.get_selected_items().empty():
		var note = Global.note_list[$NoteList.get_selected_items()[0]]
		print($NoteList.get_selected_items()[0])
		print(note.title)
		if note.in_scene:
			note.delete_note()
			#might change to close if continue to have that stupid error
		else:
			note.deleted = true
			Global.notes_to_save.append(note)
			Global.note_list.erase(note)
			get_parent().update_note_list = true
