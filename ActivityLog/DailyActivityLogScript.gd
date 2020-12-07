extends Panel

var selected_date = OS.get_date()
var selected_line

var calendar = load("res://Calendar/Calendar.tscn").instance()

func _ready():
	$EditPanel.visible = false
	$DailyActivityList.populate_list(selected_date)
	
	calendar.hide_calendar()
	calendar.connect("date_updated", self, "_on_calendar_update")
	add_child(calendar)
	
	$SelectedDateLabel.text = calendar.get_text_date()

func _process(_delta):
	pass
	"""
some cool code here, especially how _set_owner is coded:
	
	if Input.is_action_just_released('ui_snapshot'):
		if get_focus_owner():
			print(get_focus_owner())
			var popup_scene = PackedScene.new()
			var scene_root = get_focus_owner()
			_set_owner(scene_root, scene_root)
			popup_scene.pack(scene_root)
			ResourceSaver.save('res://DefaultPopupScene.tscn', popup_scene)
			print('saved popup as scene'')
		else:
			print('')
		#pack it up!

#FROM GITHUB:
func _ready():
	var scene = PackedScene.new()
	var scene_root = $Player
	_set_owner(scene_root, scene_root)
	scene.pack(scene_root)
	ResourceSaver.save('user://SavedPlayer.tscn', scene) # or .scn to avoid people messing with it

func _set_owner(node, root):
	if node != root:
		node.owner = root
	for child in node.get_children():
		_set_owner(child, root)
"""

func _on_NewLogButton_button_up():
	selected_date = OS.get_date()
	$DailyActivityList.create_new_line()
	edit_line()


func _on_EditDoneButton_button_up():
	$EditPanel.visible = false
	$DailyActivityList.populate_list(selected_date)
	get_parent().save_activity_line(selected_line)

func _on_EditButton_button_up():
	edit_line()


func edit_line():
	selected_line = $DailyActivityList.get_selected_line()
	if selected_line:
		$EditPanel.set_edit_mode()
		$EditPanel.visible = true
		$EditPanel.set_editables(selected_line)


func _on_BackButton_button_up():
	calendar.back_one_day()
	# big code, find done calendar online, either godot one or python that can change to godot
	# if nothing good, could send request to python backend for all date processing needs
	#if selected_date["day"] > 1:
	#	selected_date["day"] -= 1
	#elif selected_date["month"] > 0:
	#	selected_date["month"] -= 1


func _on_ForwardButton_button_up():
	calendar.forward_one_day()


func _on_DeleteButton_button_up():
	delete_line()


func delete_line():
	selected_line = $DailyActivityList.get_selected_line()
	if selected_line:
		selected_line.deleted = true
		$DailyActivityList.populate_list(selected_date)
		get_parent().save_activity_line(selected_line)


func _on_ViewButton_button_up():
	edit_line()
	$EditPanel.set_view_mode()


func _on_CalendarButton_button_up():
	calendar.show_calendar()


func _on_calendar_update():
	update_date_fields()
	
	
func update_date_fields():
	$SelectedDateLabel.text = calendar.get_text_date()
