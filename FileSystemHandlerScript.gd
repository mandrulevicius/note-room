extends Node

var activity_line_scene = load("res://ActivityLog/ActivityLogLineScene.tscn")
var note_scene = load("res://Note/NoteScene.tscn")

var current_date = OS.get_date()
var current_path

var year_path = str(current_date["year"]) + "/"
var month_path = str(current_date["month"]) + "/"
var day_path = str(current_date["day"]) + "/"

var time = 0

const DATA_PATH = "user://Data/"
const ACTIVITY_LOG_PATH = "ActivityLog/"
const ARCHIVE_PATH = "Archive/"
const CURRENT_PATH = "Current/"
const NOTES_PATH = "Notes/"


func _ready():
	load_activity_log()
	load_notes()


func _process(delta):
	time += delta
	if time > 1:
		time = 0
		save_notes()


func save_text_file(text, path):
	#print("Saving file ", path)
	var f = File.new()
	var err = f.open(path, File.WRITE)
	if err != OK:
		printerr("Could not write file, error code ", err)
		return false
	f.store_string(text)
	f.close()
	return true


func load_text_file(full_path):
	#print("trying to load: ", full_path)
	var file = File.new()
	var err = file.open(full_path, File.READ)
	if err != OK:
		printerr("Could not open file, error code ", err)
		return ""
	var text = file.get_as_text()
	file.close()
	return text


func load_activity_log():
	#print("load_todays_activity_log")
	# should load whole log?
	current_path = (DATA_PATH + ACTIVITY_LOG_PATH + CURRENT_PATH + 
		year_path + month_path + day_path)
		
	var dir = Directory.new()
	if not dir.dir_exists(current_path):
		dir.make_dir_recursive(current_path)
	
	var open_path_error = dir.open(current_path)
	if open_path_error != OK:
		printerr("Could open directory, error code ", open_path_error)
	else:
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		var loaded_text
		while file_name != "":
			loaded_text = load_text_file(current_path + file_name)
			if loaded_text != "":
				var activity_line = activity_line_scene.instance()
				activity_line.load_from_text(loaded_text)
				Global.activity_log.append(activity_line)
			file_name = dir.get_next()
			
		#print("loaded activity log: ", Global.activity_log)


func save_activity_line(activity_line):
	#print("save_todays_activity_log, ", str(activity_line))
	
	var new_text = activity_line.save_to_text()
	
	current_path = (DATA_PATH + ACTIVITY_LOG_PATH + CURRENT_PATH + 
		year_path + month_path + day_path)
		
	var dir = Directory.new()
	if not dir.dir_exists(current_path):
		dir.make_dir_recursive(current_path)
	
	var open_path_error = dir.open(current_path)
	if open_path_error != OK:
		printerr("Could open directory, error code ", open_path_error)
	else:
		if dir.file_exists(str(activity_line.id)):
			var file = File.new()
			var open_file_error = file.open(current_path + str(activity_line.id), File.READ)
			if open_file_error != OK:
				printerr("Could open file id %, error code %" % [str(activity_line.id), open_file_error])
			else:
				var old_text = file.get_as_text()
				if old_text != new_text:
					var archive_path = (DATA_PATH + ACTIVITY_LOG_PATH + ARCHIVE_PATH + 
						year_path + month_path + day_path)
					
					if not dir.dir_exists(archive_path):
						dir.make_dir_recursive(archive_path)
						
					var copy_error = dir.copy(current_path + str(activity_line.id), archive_path +
						 str(activity_line.id) + "_" + str(OS.get_unix_time()))
					if copy_error != OK:
						printerr("Could not archive old file, error code ", copy_error)
						return
					file.close()
					save_text_file(new_text, current_path + str(activity_line.id))
				else:
					print("app data = file data, saving skipped")
		else:
			save_text_file(new_text, current_path + str(activity_line.id))


func load_notes():
	#print("load_notes")
	current_path = (DATA_PATH + NOTES_PATH + CURRENT_PATH)
		
	var dir = Directory.new()
	if not dir.dir_exists(current_path):
		dir.make_dir_recursive(current_path)
	
	var open_path_error = dir.open(current_path)
	if open_path_error != OK:
		printerr("Could not open directory, error code ", open_path_error)
	else:
		dir.list_dir_begin(true)
		var dir_name = dir.get_next()
		while (dir_name != "") and dir.current_is_dir():
			var note_year_path = dir_name + "/"
			var year_dir = Directory.new()
			var open_year_error = year_dir.open(current_path + note_year_path)
			if open_year_error != OK:
				printerr("Could not open year directory, error code ", open_year_error)
			else:
				year_dir.list_dir_begin(true)
				var month_dir_name = year_dir.get_next()
				while (month_dir_name != "") and year_dir.current_is_dir():
					var note_month_path = month_dir_name + "/"
					var month_dir = Directory.new()
					var open_month_error = month_dir.open(current_path + note_year_path + note_month_path)
					if open_month_error != OK:
						printerr("Could not open month directory, error code ", open_month_error)
					else:
						month_dir.list_dir_begin(true)
						var file_name = month_dir.get_next()
						var loaded_text
						while file_name != "":
							loaded_text = load_text_file(current_path + note_year_path + note_month_path + file_name)
							if loaded_text != "":
								var note = note_scene.instance()
								note.load_from_text(loaded_text)
								if not note.deleted:
									Global.note_list.append(note)
							file_name = month_dir.get_next()
					month_dir_name = year_dir.get_next()
			dir_name = dir.get_next()
		#print("loaded notes: ", Global.note_list)

func save_notes():
	var saves_successful = true
	if not Global.notes_to_save.empty():
		for note in Global.notes_to_save:
			var new_text = note.save_to_text()
			current_path = (DATA_PATH + NOTES_PATH + CURRENT_PATH + 
				year_path + month_path)
				
			var dir = Directory.new()
			if not dir.dir_exists(current_path):
				dir.make_dir_recursive(current_path)
			
			var open_path_error = dir.open(current_path)
			if open_path_error != OK:
				printerr("Could open directory, error code ", open_path_error)
				saves_successful = false
			else:
				if dir.file_exists(str(note.id)):
					var file = File.new()
					var open_file_error = file.open(current_path + str(note.id), File.READ)
					if open_file_error != OK:
						printerr("Could open file id %, error code %" % [str(note.id), open_file_error])
						saves_successful = false
					else:
						var old_text = file.get_as_text()
						
						if old_text != new_text:
							# ignore position and index in scene in comparison
							var old_note = note_scene.instance()
							old_note.load_from_text(old_text)
							old_note.rect_position = note.rect_position
							old_note.index_in_scene = note.index_in_scene
							old_text = old_note.save_to_text()
							if old_text != new_text:
								var archive_path = (DATA_PATH + NOTES_PATH + ARCHIVE_PATH + 
									year_path + month_path + day_path)
								
								if not dir.dir_exists(archive_path):
									dir.make_dir_recursive(archive_path)
									
								var copy_error = dir.copy(current_path + str(note.id), archive_path +
									 str(note.id) + "_" + str(OS.get_unix_time()))
								if copy_error != OK:
									printerr("Could not archive old note file, error code ", copy_error)
									saves_successful = false
								else:
									file.close()
									if not save_text_file(new_text, current_path + str(note.id)):
										saves_successful = false
							else:
								file.close()
								if not save_text_file(new_text, current_path + str(note.id)):
									saves_successful = false
						else:
							pass
							#print("app data = file data, saving skipped")
				else:
					if not save_text_file(new_text, current_path + str(note.id)):
						saves_successful = false
		if saves_successful:
			#print("all saves successful")
			Global.notes_to_save.clear()
