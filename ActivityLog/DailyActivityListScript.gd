extends ItemList

var activity_line_scene = load("res://ActivityLog/ActivityLogLineScene.tscn")

var single_day_log = []

#var selected_line

func _ready():
	pass # Replace with function body.


#func _process(delta):
#	pass


func create_new_line():
	var new_activity_line = activity_line_scene.instance()
	if Global.activity_log.empty():
		new_activity_line.id = 0
	else:
		new_activity_line.id = Global.activity_log.back().id + 1
	Global.activity_log.append(new_activity_line)
	add_line(new_activity_line)
	single_day_log.append(new_activity_line)
	select(single_day_log.size() - 1)


func add_line(new_line):
	#add_item(new_line.description)
	#add_item(str(new_line.duration))
	#add_item(new_line.type)
	# add padding/formatting
		
	add_item(new_line.description)
	# line type as icon
	# autofill duration/ manual fill duration in full/detailed view
	


func populate_list(date):
	clear()
	single_day_log.clear()
	for line in Global.activity_log:
		# will need to update with date check function when dealing with more than one day
		#if (line.date.hash() == date.hash()) and not line.deleted: #hashes dont match if generated during different sessions
		#	single_day_log.append(line)
		# TEMP WORKAROUND: FULL ACTIVITY LOG IS CURRENTLY ONLY ONE DAY ANYWAY
		if not line.deleted:
			single_day_log.append(line)
	if not single_day_log.empty():
		for line in single_day_log:
			add_line(line)
	#print("full log: ", str(Global.activity_log[0].date))
	#print("date: ", str(date))
	#print("full single day log: ", str(single_day_log))
	#print("full log: ", str(Global.activity_log[2].deleted))


func get_selected_line():
	if get_selected_items().empty():
		return false
	else:
		return single_day_log[get_selected_items()[0]]


func _on_DailyActivityList_item_rmb_selected(_index, _at_position):
	$DailyActPopupMenu.popup(Rect2(get_viewport().get_mouse_position(), Vector2(50, 50)))
	$DailyActPopupMenu.add_item("(copy?)")
	$DailyActPopupMenu.add_item("edit")
	$DailyActPopupMenu.add_item("delete")


func _on_DailyActPopupMenu_popup_hide():
	$DailyActPopupMenu.clear()


func _on_DailyActPopupMenu_index_pressed(index):
	if index == 0:
		pass
	if index == 1:
		get_parent().edit_line()
	if index == 2:
		get_parent().delete_line()
