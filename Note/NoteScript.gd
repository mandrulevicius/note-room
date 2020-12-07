extends Panel
#Note Class

# TODO add _init() for INITIALIZATION, ON READY IS ONLY WHEN ADDED TO SCENE!
# not sure if I need it now, but might have problems later if I dont have it.

# core information
var id = 0
var in_scene = false

var title = ""
var text = ""
var type = "text" # text/checklist/image/gif/video/container?

var creation_timestamp
var last_modify_timestamp #? history?
var due_timestamp

# not sure I want to complicate this way, maybe just have seperate custom containers
# do basic activity log, should help see things in perspective
#var parent
#var children = []

var previous_links = []
var next_links = []

var tags
var categories

var comments = ""

var deleted = false

var index_in_scene = -1

# subnodes - Content Node is not the same as text_content, all triggers on latter
var text_content = TextEdit.new()

# process variables
var dragging = false
var initial_mouse_position
var initial_note_position = self.rect_position

var old_content

# onready to avoid loading hundreds of styles into my object array
onready var default_style = load("res://Note/NoteDefaultStyle.tres")
onready var focused_style = load("res://Note/NoteFocusedStyle.tres")
onready var mouseover_style = load("res://Note/NoteMouseoverStyle.tres")
onready var focused_mouseover_style = load("res://Note/NoteFocusedMouseoverStyle.tres")

var focused = false
var mouseover = false

onready var default_text_popup_scene = load("res://DefaultPopupScene.tscn")
var default_text_popup_node

var last_focused_textbox
var last_focused_text_pos = []

var last_context_menu_choice

func _ready():
	in_scene = true
	$Title.hint_tooltip = str(id)
	hint_tooltip = str(Global.note_list)
	
	$Title.text = title
	
	text_content.rect_min_size = Vector2(256, 74)
	text_content.connect("text_changed", self, "_on_text_content_text_changed")
	text_content.connect("focus_exited", self, "_on_text_content_focus_exited")
	text_content.connect("focus_entered", self, "_on_text_content_focus_entered")
	text_content.connect("mouse_exited", self, "_on_text_content_mouse_exited")
	text_content.connect("mouse_entered", self, "_on_text_content_mouse_entered")
	text_content.connect("gui_input", self, "_on_text_content_gui_input")
	text_content.context_menu_enabled = false
	text_content.text = text
	#text_content.set("mouse_filter", MOUSE_FILTER_PASS)
	#text_content.mouse_filter = MOUSE_FILTER_PASS
	$Content.add_child(text_content)
	
	if comments != "":
		$Comments.text = comments
		$Comments.show()
	
	resize_text_content($Comments.visible)
	
	default_text_popup_node = default_text_popup_scene.instance()
	default_text_popup_node.connect("index_pressed", self, "_on_Default_Text_PopupMenu_index_pressed")
	default_text_popup_node.connect("focus_entered", self, "_on_Default_Text_PopupMenu_focus_entered")
	default_text_popup_node.connect("focus_exited", self, "_on_Default_Text_PopupMenu_focus_exited")
	default_text_popup_node.connect("mouse_entered", self, "_on_Default_Text_PopupMenu_mouse_entered")
	default_text_popup_node.connect("popup_hide", self, "_on_Default_text_PopupMenu_hide")
	
	add_child(default_text_popup_node)

	$Title.clear_undo_history()
	$Comments.clear_undo_history()
	text_content.clear_undo_history()
	

func load_from_text(loaded_text):
	if loaded_text != "":
		var text_list = loaded_text.split("|")
		id = int(text_list[0])
		#in_scene = bool(text_list[1])
		if text_list[1] == "False":
			in_scene = false
		elif text_list[1] == "True":
			in_scene = true
			self.rect_position.x = float(text_list[9])
			self.rect_position.y = float(text_list[10])
		title = text_list[2]
		text = text_list[3]
		type = text_list[4]
		creation_timestamp = int(text_list[5])
		last_modify_timestamp = int(text_list[6])
		due_timestamp = text_list[7]
		#previous_links = text_list[8]
		#next_links
		
		# tags, categories
		
		# ...
		
		comments = text_list[8]
		
		if text_list[11] == "False":
			deleted = false
		elif text_list[11] == "True":
			deleted = true
			
		index_in_scene = int(text_list[12])
	
func save_to_text():
	var text_to_save = (str(id) + "|" + str(in_scene) + "|" + title + "|" + text + "|" + type + "|"
		 + str(creation_timestamp) + "|" + str(last_modify_timestamp) + "|" + str(due_timestamp) + "|"
		+ comments + "|" + str(self.rect_position.x) + "|" + str(self.rect_position.y) + "|"
		 + str(deleted)  + "|" + str(index_in_scene))
	return text_to_save


func _process(_delta):
	if dragging:
		var mousepos = get_viewport().get_mouse_position()
		self.rect_position = mousepos - initial_mouse_position + initial_note_position


func _on_Note_gui_input(event):
	if event is InputEventMouseButton:
		#print("note mouse pressed ", str(title))
		get_parent().selected_node = self
		grab_focus()
		#print("NOTE SELECTED: ", str(self))
		get_parent().move_child(self, get_parent().get_child_count() - 1)
		index_in_scene = get_index()
		get_parent().update_all_indexes_in_scene()
		if event.button_index == BUTTON_LEFT and event.pressed:
			dragging = !dragging
			initial_mouse_position = get_viewport().get_mouse_position()
			initial_note_position = self.rect_position
		elif event.button_index == BUTTON_LEFT and !event.pressed:
			dragging = !dragging
			if Global.notes_to_save.find(self) == -1:
				Global.notes_to_save.append(self)
		
		if event.button_index == BUTTON_RIGHT:
			$PopupMenu.popup(Rect2(get_viewport().get_mouse_position(), Vector2(50, 50)))
			$PopupMenu.add_item("(copy?)")
			$PopupMenu.add_item("close")
			$PopupMenu.add_item("delete")
			if $Comments.text == "" and not $Comments.visible:
				$PopupMenu.add_item("show comment box")
			elif $Comments.text == "" and $Comments.visible:
				$PopupMenu.add_item("hide comment box")
			
	# basic mobile
	elif event is InputEventScreenTouch:
		if event.pressed and event.get_index() == 0:
			self.position = event.get_position()


func _on_Title_text_changed():
	title = $Title.text
	get_parent().update_note_list = true


func _on_Comments_text_changed():
	comments = $Comments.text
	get_parent().update_note_list = true


func _on_text_content_text_changed():
	text = text_content.text
	get_parent().update_note_list = true
	

func _on_text_content_focus_exited():
	get_parent().selected_node = null
	#print("NOTE DESELECTED: ", str(self))
	if old_content != text_content.text:
		Global.notes_to_save.append(self)
	remove_focus_highlight()
	text_content.deselect()
	
	
func _on_text_content_focus_entered():
	get_parent().selected_node = self
	#print("NOTE SELECTED: ", str(self))
	get_parent().move_child(self, get_parent().get_child_count() - 1)
	index_in_scene = get_index() # redundant because of updating all?
	get_parent().update_all_indexes_in_scene()
	old_content = text_content.text
	highlight_focus()
	

func _on_Title_focus_exited():
	get_parent().selected_node = null
	#print("NOTE DESELECTED: ", str(self))
	if old_content != $Title.text:  # might not work with some types of data
		Global.notes_to_save.append(self)
	remove_focus_highlight()
	#print("title focus exited ", str(title))
	$Title.deselect()
	#print("Deselecting title text")


func _on_Title_focus_entered():
	get_parent().selected_node = self
	#print("NOTE SELECTED: ", str(self))
	get_parent().move_child(self, get_parent().get_child_count() - 1)
	# use call_deferred to avoid error?
	# Test to make sure it doesnt break anything and gets executed in time to save
	index_in_scene = get_index()
	get_parent().update_all_indexes_in_scene()
	old_content = $Title.text
	highlight_focus()
	#print("title focus entered ", str(title))

func _on_NoteCloseButton_button_up():
	close_note()


func copy_note():
	pass


func close_note():
	in_scene = false
	Global.notes_to_save.append(self)
	get_parent().update_note_list = true
	get_parent().remove_child(self)
	# forgets position because save happens only after some time, when child is already removed?


func delete_note():
	deleted = true
	Global.notes_to_save.append(self)
	Global.note_list.erase(self)
	get_parent().update_note_list = true
	get_parent().remove_child(self)


func _on_PopupMenu_index_pressed(index):
	match index:
		0:
			copy_note()
		1:
			close_note()
		2:
			delete_note()
		3:
			$Comments.visible = !$Comments.visible
			resize_text_content($Comments.visible)
	
	last_context_menu_choice = index
	
	"""
	if index == 0:
		copy_note()
	elif index == 1:
		close_note()
	elif index == 2:
		delete_note()
	elif index == 3: #careful if you add stuff after this, might get wrong index cause not always added
		$Comments.visible = !$Comments.visible
		resize_text_content($Comments.visible)
		
	last_context_menu_choice = index
	"""

func resize_text_content(comments_visible):
	if comments_visible:
		text_content.rect_size = Vector2(256, 74)
	else:
		text_content.rect_size = Vector2(256, 120)


func _on_Comments_focus_entered():
	get_parent().selected_node = self
	#print("NOTE SELECTED: ", str(self))
	get_parent().move_child(self, get_parent().get_child_count() - 1)
	index_in_scene = get_index()
	get_parent().update_all_indexes_in_scene()
	old_content = $Comments.text
	highlight_focus()


func _on_Comments_focus_exited():
	get_parent().selected_node = null
	#print("NOTE DESELECTED: ", str(self))
	if old_content != $Comments.text:
		Global.notes_to_save.append(self)
	remove_focus_highlight()
	$Comments.deselect()


func _on_PopupMenu_popup_hide():
	$PopupMenu.clear()
	if last_context_menu_choice == 3:
		$Comments.grab_focus()
	#print("popup hide ", str(title))
	
	
func highlight_focus():
	if mouseover:
		set("custom_styles/panel", focused_mouseover_style)
	else:
		set("custom_styles/panel", focused_style)
	focused = true
		
		
func remove_focus_highlight():
	if mouseover:
		set("custom_styles/panel", mouseover_style)
	else:
		set("custom_styles/panel", default_style)
	focused = false
		
		
func _on_Note_focus_entered():
	highlight_focus()
	#print("note focus entered ", str(title))


func _on_Note_focus_exited():
	remove_focus_highlight()
	get_parent().selected_node = null
	#print("note focus exited ", str(title))


func _on_PopupMenu_focus_entered():
	highlight_mouseover()
	highlight_focus()
	#print("popup focus entered ", str(title))


func _on_PopupMenu_focus_exited():
	remove_focus_highlight()
	remove_mouseover_highlight()
	#print("popup focus exited ", str(title))


func highlight_mouseover():
	mouseover = true
	if focused:
		set("custom_styles/panel", focused_mouseover_style)
	else:
		set("custom_styles/panel", mouseover_style)
	
	
func remove_mouseover_highlight():
	mouseover = false
	if focused:
		set("custom_styles/panel", focused_style)
	else:
		set("custom_styles/panel", default_style)


func _on_Note_mouse_entered():
	highlight_mouseover()
	#print("note mouse entered ", str(title))


func _on_Note_mouse_exited():
	remove_mouseover_highlight()
	#print("note mouse exited ", str(title))


# old redundant code
#func _on_Title_gui_input(event):
#	if event is InputEventMouseButton:
#		highlight_focus()
#		print("gui input")


func _on_Title_mouse_entered():
	#print("title mouse entered ", str(title))
	highlight_mouseover()


func _on_Title_mouse_exited():
	#print("title mouse exited ", str(title))
	remove_mouseover_highlight()


func _on_Comments_mouse_entered():
	highlight_mouseover()


func _on_Comments_mouse_exited():
	remove_mouseover_highlight()


func _on_NoteCloseButton_mouse_entered():
	highlight_mouseover()


func _on_NoteCloseButton_mouse_exited():
	remove_mouseover_highlight()


func _on_PopupMenu_mouse_entered():
	#print("popup mouse entered ", str(title))
	highlight_mouseover()
	# mouse exited not needed, relevant code on focus exited
	# need this because onPopupFocusEntered happens before onNoteMouseExited
	# onNoteFocusExited->onPopupFocusEntered->OnNoteMouseExited->OnPopupMouseEntered 
	
	# in default text popup menu, order seems different:
	# titleMouseExited->titleFocusExited


func popup_default_text_context_menu(event, textbox_node:TextEdit):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		#print("PRESSED TEXTBOX: ", str(textbox_node.name))
		#if get_parent().previous_focused_textbox:
		#	print("PREVIOUSTEXTBOX: ", str(get_parent().previous_focused_textbox.name))
		#else:
		#	print("NOPREVIOUSTEXTBOX")
			
		if get_parent().previous_focused_textbox and get_parent().previous_focused_textbox != textbox_node:
			get_parent().previous_focused_textbox.deselect()
			
		if get_parent().previous_focused_textbox != textbox_node:
			get_parent().previous_focused_textbox = textbox_node
		else:
			get_parent().previous_focused_textbox = null
			
		last_focused_textbox = textbox_node
		last_focused_text_pos = get_textbox_selection_pos(textbox_node)

		default_text_popup_node.rect_position = get_viewport().get_mouse_position()
		default_text_popup_node.popup()
		if not last_focused_text_pos.empty():
			last_focused_textbox.select(last_focused_text_pos[0], last_focused_text_pos[1],
				last_focused_text_pos[2], last_focused_text_pos[3])
		#print("rightclicked on ", str(title))


func _on_Comments_gui_input(event):
	#last_focused_text_pos = $Comments.get_selection_text()
	popup_default_text_context_menu(event, $Comments)


func _on_Title_gui_input(event):
	#last_focused_text_pos = $Title.get_selection_text()
	popup_default_text_context_menu(event, $Title)
	
	#random code testing doubleclick
	if event is InputEventMouseButton and event.doubleclick:
		print("double pressed")
		#toggle readonly?? dont think I wanna go that way, but we will see


func _on_text_content_gui_input(event: InputEvent):
	#last_focused_text_pos = text_content.get_selection_text()
	popup_default_text_context_menu(event, text_content)


func get_textbox_selection_pos(text_node: TextEdit):
	var selection_text_pos = []
	#print("SELECTION ACTIVE STATUS: ", str(text_node.is_selection_active()))
	if text_node.is_selection_active():
		selection_text_pos.append(text_node.get_selection_from_line())
		selection_text_pos.append(text_node.get_selection_from_column())
		selection_text_pos.append(text_node.get_selection_to_line())
		selection_text_pos.append(text_node.get_selection_to_column())
	return selection_text_pos


func _on_text_content_mouse_exited():
	remove_mouseover_highlight()
	
	
func _on_text_content_mouse_entered():
	highlight_mouseover()


func _on_Default_Text_PopupMenu_index_pressed(index):
	#print("POPUP INDEX: ", str(index))
	#print("SELECTION TEXT: ", last_focused_text_pos)
	if index == 0:
		last_focused_textbox.undo()
	elif index == 1:
		last_focused_textbox.redo()
	elif index == 3:
		#if not last_focused_text_pos.empty():
		#	last_focused_textbox.select(last_focused_text_pos[0], last_focused_text_pos[1],
		#		last_focused_text_pos[2], last_focused_text_pos[3])
		last_focused_textbox.cut()
	elif index == 4:
		#if not last_focused_text_pos.empty():
		#	last_focused_textbox.select(last_focused_text_pos[0], last_focused_text_pos[1],
		#		last_focused_text_pos[2], last_focused_text_pos[3])
		last_focused_textbox.copy()
	elif index == 5:
		last_focused_textbox.paste()
	elif index == 7:
		last_focused_textbox.select_all()
	elif index == 8:
		pass
		#last_focused_textbox.text = ""
		# undo doesnt work on this even in standard. so be careful. might want to just turn it off.


func _on_Default_Text_PopupMenu_focus_entered():
	highlight_mouseover()
	highlight_focus()
	#print("Default_Text_PopupMenu focus entered ", str(title))


func _on_Default_Text_PopupMenu_focus_exited():
	remove_focus_highlight()
	remove_mouseover_highlight()
	#print("_Default_Text popup focus exited ", str(title))


func _on_Default_Text_PopupMenu_mouse_entered():
	highlight_mouseover()
	#print("_Default_Text popup mouse entered ", str(title))


func _on_Default_text_PopupMenu_hide():
	last_focused_textbox.grab_focus()

# Memento mori:

#                      :::!~!!!!!:.
#                  .xUHWH!! !!?M88WHX:.
#                .X*#M@$!!  !X!M$$$$$$WWx:.
#               :!!!!!!?H! :!$!$$$$$$$$$$8X:
#              !!~  ~:~!! :~!$!#$$$$$$$$$$8X:
#             :!~::!H!<   ~.U$X!?R$$$$$$$$MM!
#             ~!~!!!!~~ .:XW$$$U!!?$$$$$$RMM!
#               !:~~~ .:!M"T#$$$$WX??#MRRMMM!
#               ~?WuxiW*`   `"#$$$$8!!!!??!!!
#             :X- M$$$$       `"T#$T~!8$WUXU~
#            :%`  ~#$$$m:        ~!~ ?$$$$$$
#          :!`.-   ~T$$$$8xx.  .xWW- ~""##*"
#.....   -~~:<` !    ~?T#$$@@W@*?$$      /`
#W$@@M!!! .!~~ !!     .:XUW$W!~ `"~:    :
##"~~`.:x%`!!  !H:   !WM$$$$Ti.: .!WUn+!`
#:::~:!!`:X~ .: ?H.!u "$$$B$$$!W:U!T$$M~
#.~~   :X@!.-~   ?@WTWo("*$$$W$TH$! `
#Wi.~!X$?!-~    : ?$$$B$Wu("**$RM!
#$R@i.~~ !     :   ~$$$$$B$$en:``
#?MXT@Wx.~    :     ~"##*$$$$M~
