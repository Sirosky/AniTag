extends Node

var name_eng = 1 #Prefer english names
var bulk_mode = 0

func _ready():
	pass # Replace with function body.

func dir_rename(entry):
	#Rename a single entry directory
	var dir_temp = Directory.new()
	var dir_old = global.db[entry]["path"]
	var dir_new = ""
	#Find base path
	var str_pos = global.db[entry]["path"].find_last("/")
	var dir_base = global.db[entry]["path"].left(str_pos+1)
	
	if name_eng == 1:
		if global.db[entry]["name_eng"] == "": #No english name option
			dir_new = str(dir_base + global.db[entry]["anidb_name"])
		else:
			dir_new = str(dir_base + global.db[entry]["name_eng"])
	
	var illegal_pos = dir_new.find_last(":")
	if illegal_pos != -1: #Remove invalid characters
		dir_new.erase(illegal_pos, 1)
		global.Mes.message_send("Illegal character ':' excluded.")
	
	if dir_temp.dir_exists(dir_old):
		dir_temp.rename(dir_old, dir_new)
		global.db[entry]["path"] = dir_new
		global.json_write("user://db/"+global.db_name,global.db)
		global.Mes.message_send("Directory renamed.")
	else:
		global.Mes.message_send("Original directory not found. Rename cancelled.")

