extends Node


func _ready():
	yield(get_tree(), "idle_frame") # lets FileSystemHandler load notes from file
	load_notes_into_scene()


#func _process(_delta):
#	pass


func load_notes_into_scene():
	for note in Global.note_list:
		if note.in_scene and not note.deleted:
			get_parent().add_child(note)
	for note in Global.note_list:
		if note.in_scene and not note.deleted:
			#print("note %s index_var: %s, index: %s " % [note.title, note.index_in_scene, note.get_index()])
			get_parent().move_child(note, note.index_in_scene)
			#print("index after move: ", str(note.get_index()))

