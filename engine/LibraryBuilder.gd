extends Node

var file_search = FileSearch.new() #Launch file search class
var active = 0 #Whether loading
var refreshing = 0 #If in refreshing mode, don't nuke everything
var thread = Thread.new()
var dirs_temp #Holds array of paths generated by thread

onready var LibLoader = get_node("/root/Main/Library/LibraryLoader")

onready var Popups = get_node("/root/Main/Popups") 
onready var LoadPanel = get_node("../../Popups/LoadPanel")
onready var LoadStatus = get_node("../../Popups/LoadPanel/LoadStatus")

#Buttons
onready var ButLoad = get_node("/root/Main/HBoxContainer/Panel/LeftDisplay/TopBar/TopBarHBox/ButLoad")
onready var ButBuild = get_node("/root/Main/HBoxContainer/Panel/LeftDisplay/TopBar/TopBarHBox/ButBuild")
onready var ButRandom = get_node("/root/Main/HBoxContainer/Panel/LeftDisplay/TopBar/TopBarHBox/ButRandom")
onready var ButUpdate = get_node("/root/Main/HBoxContainer/ItemDisplay/VBoxContainer/TopHBox/ConfigVBox/ButUpdate")
onready var ButDir = get_node("/root/Main/HBoxContainer/ItemDisplay/VBoxContainer/TopHBox/ConfigVBox/ButDir")
onready var ButDB = get_node("/root/Main/HBoxContainer/ItemDisplay/VBoxContainer/TopHBox/ConfigVBox/ButDB")
onready var ButLink = get_node("/root/Main/HBoxContainer/ItemDisplay/VBoxContainer/TopHBox/ConfigVBox/ButLink")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func library_build_init():
	#Starts the method chain for building a library
	
	#Show loading elements
	active = 1
	Popups.visible = 1
	LoadPanel.visible = 1
	LoadStatus.visible = 1
	global.load_status_prepend = "Loading- "
	

	library_manage_thread(0) #Start thread

	
func library_manage_thread(opt):
	#Method for choosing which threads to start
	#if (thread.is_active()):
	#	print("Thread active, returning")
	#	return
	if opt == 0: #Iterate folders
		thread.start(self, "thread_iterate_folder", global.dir_path)
	
	if opt == 1:
		dirs_temp = thread.wait_to_finish() #Wait for thread to finish before proceeding
		thread.start(self, "thread_scan_exclusions", global.filter_vid_regex)

func thread_iterate_folder(path):
	dirs_temp  = file_search.search_iterate_folder(path, 1) #Returns array of paths
	call_deferred("library_manage_thread", 1) #Call the method for then next stage
	#print(dirs_temp)
	return dirs_temp

func thread_scan_exclusions(filter):
	#Remove folders that don't have video files
	var dirs_duplicate = dirs_temp.duplicate() #Temporary duplicate we will use as the original copy. Won't be modified.
	#Entries without videos will be removed with from dirs_temp, but dirs_duplicate can't be modified
	
	global.load_status_prepend = "Scanning- "
	
	for i in dirs_duplicate: #Loop through array of found paths
		global.load_status = i #Updated UI
		var search = file_search.search_regex_full_path(filter, i, 0) #Make sure this dir actually has videos
		
		#Delete from array if no video found
		if dirs_duplicate.size()>0: #
			var i_index = dirs_temp.find(i) #Find index of i
			
			if i_index>-1: #Find directory in array being modified			
				if search.size()<1: #Found no videos
					dirs_temp.remove(i_index)
					global.load_status = str(i)
			else:
				print("Directory not found")
	
	
	call_deferred("library_build") #Call the method for then next stage
	return dirs_temp

func library_build():
	#This only builds a skeleton library
	var dirs = thread.wait_to_finish()
	var db = global.json_read("res://settings/db_template.json") #read json
	
	if refreshing == 0: #Building a brand new library
		
		for i in dirs:
			var index = str(i.get_file()) #Get name of the folder, which is used as the indentifier
			var dbalt = db["Template"].duplicate() #duplicate any entry as a template
			
			db[index] = dbalt #Merge in as a new entry!
			db[index]["name"] = index
			db[index]["anidb_name"] = index
			db[index]["path"] = i
		
		db["_Settings"]["main_path"] = global.dir_path
			
		db.erase("Template")
		global.json_write("user://db/"+global.db_name, db)
		
		global.Mes.message_send("Library built.")
		global.db_path = "user://db/"+global.db_name #Load our shiny new library
		LibLoader.library_load()
		
	if refreshing == 1: #Just refreshing a current library
		print("Refreshing")
		
		for i in dirs:
			var index = str(i.get_file())
			
			if global.db.has(index) == true: #The target directory exists in the current database
				#global.db[index]["name"] = index
				#global.db[index]["anidb_name"] = index
				global.db[index]["path"] = i
			else: #Make a new entry since it doesn't exist
				var dbalt = db["Template"].duplicate() #duplicate any entry as a template
				
				global.db[index] = dbalt #Merge in as a new entry!
				global.db[index]["name"] = index
				global.db[index]["anidb_name"] = index
				global.db[index]["path"] = i
		
		#Delete entries that are no longer around (make this an option)
		for i in global.db:
			var dir = Directory.new()
			
			if i!="_Settings":
				if dir.dir_exists(global.db[i]["path"]) == false:
					print(i)
					global.db.erase(i)
		
		global.Mes.message_send("Library refresh complete.")
		global.json_write("user://db/"+global.db_name, global.db)
	
	active = 0
	refreshing = 0
	Popups.visible = 0
	LoadPanel.visible = 0
	LoadStatus.visible = 0

func _process(delta):
	if active > 0:
		if LoadStatus.visible:
			LoadStatus.text = str(str(global.load_status_prepend)+str(global.load_status))
