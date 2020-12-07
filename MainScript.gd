extends Node


var note_scene = load("res://Note/NoteScene.tscn")
var note_node

var selected_node
# doesnt work all that well, might need a more robust, centralized solution
# now seems to work alright, if only for notes

var update_note_list = false

var previous_focused_textbox


func _ready():
	update_note_list = true

func _process(_delta):
		
	if update_note_list:
		$NoteListPanel/NoteList.update_list()
		update_note_list = false
		
	#debugging
	if selected_node:
		$SelectedNote.text = selected_node.title
	else:
		$SelectedNote.text = "NONE"
		


func add_to_scene(note):
	add_child(note) # adding even a few hundred nodes here slows the game way down, due to custom style big panels


#move to notehandler?
func create_new_note():
	var new_id = 0
	if not Global.note_list.empty():
		var last_note = Global.note_list.back()
		new_id = last_note.id + 1
	var new_note = note_scene.instance()
	new_note.id = new_id
	Global.note_list.append(new_note)
	add_to_scene(new_note)
	new_note.index_in_scene = new_note.get_index()
	update_note_list = true
	
	
func save_activity_line(activity_line):
	$FileSystemHandler.save_activity_line(activity_line)
	

func _on_DailyActivityList_item_selected(index):
	#selected_node = $DailyActivityLog/DailyActivityList
	#print("DAILY ACTIVITY LIST SELECTED")
	pass


func update_all_indexes_in_scene():
	for note in Global.note_list:
		if note.in_scene:
			note.index_in_scene = note.get_index()
			#print("note %s index %s" % [note.title, note.index_in_scene])
			Global.notes_to_save.append(note)


# Should have notelayout as a general control parent, so i can play with alignments and containers?
	
	
# Memento mori:
"""
					   uuuuuuuuuuuuuuuuuuuuu.
				   .u$$$$$$$$$$$$$$$$$$$$$$$$$$W.
				 u$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$Wu.
			   $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$i
			  $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
		 `    $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
		   .i$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$i
		   $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$W
		  .$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$W
		 .$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$i
		 #$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$.
		 W$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$u       #$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$~
$#      `'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$i        $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$$        #$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$$         $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#$.        $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$#
 $$      $iW$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$!
 $$i      $$$$$$$#"" `'''#$$$$$$$$$$$$$$$$$#""""""#$$$$$$$$$$$$$$$W
 #$$W    `$$$#"            "       !$$$$$`           `'#$$$$$$$$$$#
  $$$     ``                 ! !iuW$$$$$                 #$$$$$$$#
  #$$    $u                  $   $$$$$$$                  $$$$$$$~
   '#    #$$i.               #   $$$$$$$.                 `$$$$$$
		  $$$$$i.                ""'#$$$$i.               .$$$$#
		  $$$$$$$$!         .   `    $$$$$$$$$i           $$$$$
		  `$$$$$  $iWW   .uW`        #$$$$$$$$$W.       .$$$$$$#
			'#$$$$$$$$$$$$#`          $$$$$$$$$$$iWiuuuW$$$$$$$$W
			   !#""    ""             `$$$$$$$##$$$$$$$$$$$$$$$$
		  i$$$$    .                   !$$$$$$ .$$$$$$$$$$$$$$$#
		 $$$$$$$$$$`                    $$$$$$$$$Wi$$$$$$#'#$$`
		 #$$$$$$$$$W.                   $$$$$$$$$$$#   ``
		  `$$$$##$$$$!       i$u.  $. .i$$$$$$$$$#""
			 '     `#W       $$$$$$$$$$$$$$$$$$$`      u$#
							W$$$$$$$$$$$$$$$$$$      $$$$W
							$$`!$$$##$$$$``$$$$      $$$$!
						   i$' $$$$  $$#'`  ""'     W$$$$
											   W$$$$!
					  uW$$  uu  uu.  $$$  $$$Wu#   $$$$$$
					 ~$$$$iu$$iu$$$uW$$! $$$$$$i .W$$$$$$
			 ..  !   '#$$$$$$$$$$##$$$$$$$$$$$$$$$$$$$$#'
			 $$W  $     '#$$$$$$$iW$$$$$$$$$$$$$$$$$$$$$W
			 $#`   `       ""#$$$$$$$$$$$$$$$$$$$$$$$$$$$
							  !$$$$$$$$$$$$$$$$$$$$$#`
							  $$$$$$$$$$$$$$$$$$$$$$!
							$$$$$$$$$$$$$$$$$$$$$$$`
							 $$$$$$$$$$$$$$$$$$$$"
"""
