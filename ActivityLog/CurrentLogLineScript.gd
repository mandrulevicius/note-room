extends Node

var id
var date
var description
var start_time
var end_time
var type # should be tag list or one type selected from static enums
#advanced: for type == exercise, add reps or other measurements?
var deleted
var duration

func _ready():
	pass # Replace with function body.


func _init():
	id = 0
	date = OS.get_date()
	description = ""
	start_time = OS.get_system_time_secs()
	end_time = start_time
	type = ""
	deleted = false
	duration = 0
	
	
func load_from_text(text):
	if text != "":
		var text_list = text.split("|")
		id = int(text_list[0])
		date = text_list[1]
		description = text_list[2]
		start_time = int(text_list[3])
		end_time = int(text_list[4])
		type = text_list[5]
		deleted = bool(text_list[6])
		if text_list[6] == "False":
			deleted = false
		elif text_list[6] == "True":
			deleted = true
		duration = int(text_list[7])
	
func save_to_text():
	var text = (str(id) + "|" + str(date) + "|" + description + "|" + str(start_time) + "|"
		+ str(end_time) + "|" + type + "|" + str(deleted) + "|" + str(duration))
	return text

#func _process(delta):
#	pass
