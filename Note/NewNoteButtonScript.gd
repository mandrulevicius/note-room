extends Button


func _ready():
	pass # Replace with function body.


#func _process(delta):
#	pass


func _on_NewNoteButton_button_up():
	get_parent().create_new_note()
