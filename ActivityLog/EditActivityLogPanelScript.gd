extends Panel

var entry

func _ready():
	pass # Replace with function body.


#func _process(delta):
#	pass


func set_editables(new_entry):
	entry = new_entry
	$DescriptionEdit.text = entry.description
	$DescriptionEdit.grab_focus()
	$TypeEdit.text = entry.type


func set_edit_mode():
	$DescriptionEdit.editable = true
	$TypeEdit.editable = true
	$StartTimeEdit.editable = true
	$EndTimeEdit.editable = true


func set_view_mode():
	$DescriptionEdit.editable = false
	$TypeEdit.editable = false
	$StartTimeEdit.editable = false
	$EndTimeEdit.editable = false
	

func _on_DescriptionEdit_text_changed(new_text):
	entry.description = new_text


func _on_TypeEdit_text_changed(new_text):
	entry.type = new_text
