extends Node
#For renaming entries and directories.

var mode_bulk = 0

onready var Popups = get_node("/root/Main/Popups")
onready var LoadPanel = get_node("/root/Main/Popups/LoadPanel") 
onready var LoadStatus = get_node("/root/Main/Popups/LoadPanel/LoadStatus") 

var mode_name = 1 #0 = custom names, 1 = anidb names, 2 = eng names

func _ready():
	pass # Replace with function body.
	
func dir_rename_bulk():
	var index = 0
	
	for i in global.db:
		Popups.visible = 1
		LoadPanel.visible = 1
		LoadStatus.visible = 1
		
		if i!= "_Settings":
			index += 1
			global.load_status = str(i + " (" + str(stepify(float(index)/float(global.db.size()-1)*100, .1)) + (")%"))
			dir_rename(i)
		yield(get_tree().create_timer(1), "timeout")
	
	Popups.visible = 0
	LoadPanel.visible = 0
	LoadStatus.visible = 0
	global.load_status = ""
	global.json_write("user://db/"+global.db_name,global.db)
	global.Mes.message_send("Directories renamed.")

func dir_rename(entry):
	#Rename a single entry directory
	
	if int(global.db[global.db_cur_key]["id"]) > -1:
	
		var dir_temp = Directory.new()
		var dir_old = global.db[entry]["path"]
		var dir_new = ""
		#Find base path
		var str_pos = dir_old.find_last("/")
		var dir_base = dir_old.left(str_pos+1)
		
		if mode_name == 0: 
			dir_new = global.db[entry]["name"]
		if mode_name == 1: 
			dir_new = global.db[entry]["anidb_name"]
		if mode_name == 2:
			if global.db[entry]["name_eng"] == "": #No english name option
				dir_new = global.db[entry]["anidb_name"]
			else:
				dir_new = global.db[entry]["name_eng"]
		
		var illegal_pos = dir_new.find_last(":")
		if illegal_pos != -1: #Remove invalid characters
			dir_new.erase(illegal_pos, 1)
			global.Mes.message_send("Illegal character ':' excluded.")
			
		illegal_pos = dir_new.find_last("?")
		if illegal_pos != -1: #Remove invalid characters
			dir_new.erase(illegal_pos, 1)
			global.Mes.message_send("Illegal character '?' excluded.")
			
		illegal_pos = dir_new.find_last("*")
		if illegal_pos != -1: #Remove invalid characters
			dir_new.erase(illegal_pos, 1)
			global.Mes.message_send("Illegal character '*' excluded.")
		
		dir_new = str(dir_base + dir_new)
		print(dir_old)
		print(dir_new)
		
		if dir_temp.dir_exists(dir_old):
			dir_temp.rename(dir_old, dir_new)
			global.db[entry]["path"] = dir_new
			if mode_bulk == 0: global.json_write("user://db/"+global.db_name,global.db)
			if mode_bulk == 0: global.Mes.message_send("Directory renamed.")
		else:
			global.Mes.message_send("Original directory not found. Rename cancelled.")

func entry_rename_bulk():
	var index = 0
	
	for i in global.db:
		Popups.visible = 1
		LoadPanel.visible = 1
		LoadStatus.visible = 1
		
		if i!= "_Settings":
			index += 1
			global.load_status = str(i + " (" + str(stepify(float(index)/float(global.db.size()-1)*100, .1)) + (")%"))
			entry_rename(i)
		yield(get_tree().create_timer(.2), "timeout")
	
	Popups.visible = 0
	LoadPanel.visible = 0
	LoadStatus.visible = 0
	global.load_status = ""
	global.json_write("user://db/"+global.db_name,global.db)
	global.Mes.message_send("Entries renamed.")

func entry_rename(entry): #Rename by AniDB name, single entry
	if int(global.db[entry]["id"]) > -1:
		var dir_temp = Directory.new()
		
		if mode_name == 1: 
			global.db[entry]["name"] = global.db[entry]["anidb_name"]
			if mode_bulk == 0: global.Mes.message_send("Entry renamed.")
		if mode_name == 2:
			global.db[entry]["name"] = global.db[entry]["name_eng"]
			
			if global.db[entry]["name"] == "": #Make sure it's not empty
				global.db[entry]["name"] = global.db[entry]["anidb_name"]
			
			if mode_bulk == 0: global.Mes.message_send("Entry renamed.")
		
		if mode_bulk == 0:
			global.json_write("user://db/"+global.db_name,global.db)
