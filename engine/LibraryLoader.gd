extends Node

onready var ViewListItem = get_node("../../HBoxContainer/Panel/LeftDisplay/ViewListItem")
onready var Messenger = get_node("/root/Main/Messenger") 

func _ready():
	pass

func library_load():
	var file_temp = File.new()
	
	if file_temp.file_exists(global.db_path):
		global.db = {}
		global.db_cur_key = ""
		global.db = global.json_read(global.db_path)
		global.db_name = global.db_path.get_file()
		if global.db.has("_Settings"): #Reading settings
			#global.settings = global.db["_Settings"].duplicate()
			global.dir_path = global.db["_Settings"]["main_path"]
			print(global.dir_path)
			#global.db.erase("_Settings")
		global.settings["General"]["main_path"] = global.db_path
		global.json_write(global.settings_path, global.settings) #Write to settings JSON
		
		#Update old saves if needed
		var needs_update = 0
		
		if global.db["_Settings"].has("version") == false: #Update version
			global.db["_Settings"]["version"] = global.anitag_version
			needs_update = 1
		elif float(global.db["_Settings"].has("version")) != global.anitag_version:
			global.db["_Settings"]["version"] = global.anitag_version
			needs_update = 1	
		
		for i in global.db: 
			if global.db[i].has("tags_user") == false and i != "_Settings":
				global.db[i]["tags_user"] = []
				needs_update = 1
		
		if needs_update == 1:
			global.json_write("user://db/"+global.db_name,global.db)
		
		ViewListItem.directory_refresh()
		Messenger.message_send(str(global.db_name) + " loaded.")
	else:
		print("File not found, cannot load database")
		
		
func settings_load():
	var file_temp = File.new()
	
	if file_temp.file_exists(global.settings_path):
		global.settings = {}
		global.settings = global.json_read(global.settings_path)
		
		if global.settings["General"]["main_path"]!="": #Autoload
			global.db_path = global.settings["General"]["main_path"]
			library_load()
	else:
		print("File not found, cannot load settings")

