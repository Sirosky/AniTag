extends ScrollContainer

var directory = ""
var but = preload("res://ui/ButShow.tscn")
var ico_exclam = preload("res://ui/themes/default/icons/exclamation.png")
var but_index = []
var but_index_filtered = []
var file_search = FileSearch.new() #Launch file search class
var but_tar #Button keep focus on
var but_tar_reset = 0 #Whether or not we resetted the focus


onready var ItemDisplay = get_node("../../../ItemDisplay")
onready var VBox = get_node("VBoxContainer")
onready var LineSearch = get_node("../HBoxFilter/LineSearch")
onready var TagPanel = get_node("/root/Main/Popups/TagPanel")
onready var par = get_node("..")

# Called when the node enters the scene tree for the first time.
func _ready():
	LineSearch.connect("text_changed",self,"_on_LineSearch_updated")

func directory_refresh():
	#Clear previously loaded stuff
	but_index = []
	global.children_delete(VBox)
	global.db_tags_count = {}
	
	#Create buttons
	
	global.db_arr = [] #Clear it
	global.db_arr_id = {}
	
	for i in global.db:
		if i!= "_Settings":
			global.db_arr.append(global.db[i]["name"])
			global.db_arr_id[global.db[i]["name"]] = i #Store id of the show name
	
	global.db_arr.sort() #Sort by alphabetical order
	
	for i in global.db_arr:
		#Load button
		if i!= "_Settings": #Don't load the settings dictionary
			var temp=but.instance()
			VBox.add_child(temp) #load button into the right container
			var node_path = NodePath(get_path_to(temp)) #locate the newly created button
			temp = get_node(node_path) #get button
			
			temp.stored_str = global.db_arr_id[i] #save identifier
			if !temp.is_connected("pressed", self, "_on_ButShow_pressed"):
				temp.connect("pressed", self, "_on_ButShow_pressed", [temp])
			temp.text = i #str(global.db[i]["name"]) #update text label
			temp.hint_tooltip = i#str(global.db[i]["name"])
			
			#Check for errors
			if global.settings["General"]["error"] == true:
				if int(global.db[temp.stored_str]["id"]) == -1:
					temp.icon = ico_exclam
					temp.hint_tooltip = "AniDB ID not assigned."
				var dir_temp = Directory.new()
				if dir_temp.dir_exists(global.db[temp.stored_str]["path"]) == false:
					temp.icon = ico_exclam
					temp.hint_tooltip = "Invalid directory"
			
			but_index.append(temp) #add this into our button array
			
			#Find tags while we're at it.
			if global.db[temp.stored_str]["anidb_tags"].size() > 0:
				for ii in global.db[temp.stored_str]["anidb_tags"]:
					if global.db_tags_count.has(ii): #Already existing inside tag db
						global.db_tags_count[ii] += 1
					elif !global.db[temp.stored_str]["tags_hidden"].has(ii) and !global.settings["General"]["tags_hidden"].has(ii):
						global.db_tags_count[ii] = 1 #Create new tag if it isn't on a blacklist
			
	global.db_tags_count = global.sort_dic_value(global.db_tags_count)
	#print(global.db_tags_count)
	
	#print(global.db[0]["name"])
	#yield(get_tree(), "idle_frame")
	but_index[0].emit_signal("pressed") #Load the first selection

	"""
	directory = file_search.search_iterate_folder(global.dir_path,1) #Returns array
	#print(str(directory))
	
	for i in directory:
		
		#Load button
		var temp=but.instance()
		get_node("VBoxContainer").add_child(temp) #load button into the right container
		
		
		var node_path=NodePath(get_path_to(temp)) #locate the newly created button
		temp=get_node(node_path) #get button
		temp.stored_str = str(i)
		temp.init()
		temp.text = temp.stored_str.get_file() #update text label
		but_index.append(temp) #add this into our button array
	"""

func directory_filter():
	var text = LineSearch.text
	but_index_filtered = []
	
	#Filter by title
	
	for i in but_index:
		if text != "":
			var pos = i.text.findn(text)
			
			if pos == -1: #Button didn't have the text we searched
				i.visible = 0
			else:
				i.visible = 1
				but_index_filtered.append(i)
		if text == "": #nothing in search bar
			i.visible = 1
			but_index_filtered.append(i)

	#Filter by tags CONTINUE HERE
	if TagPanel.filtered_tags.size() > 0:
		var arr
		var temp_index = [] #Merged with but_index_filtered
		
		if but_index_filtered.size() > 0: #Assign correct array to loop through
			arr = but_index_filtered
		else:
			arr = but_index
		
		for i in arr:
			var matches = 0
			
			for ii in TagPanel.filtered_tags:
				if global.db[i.stored_str]["anidb_tags"].has(ii): #Make sure it has ALL tags
					matches += 1
					
			if matches < TagPanel.filtered_tags.size():
				i.visible = 0
			else:
				temp_index.append(i)
		
		but_index_filtered = temp_index


func _process(delta):
	#Workaround to make sure button is always in toggled state when selected once
	if but_tar_reset == 0 and but_index.size()>0:

		for i in but_index:
			if i!=but_tar:
				i.pressed = 0
				i.toggle_mode = 0
			
		but_tar.pressed = 1		
		
	if but_tar_reset == 1:
		but_tar_reset = 0

func _on_ButShow_pressed(but):
	#print(but.stored_str)
	global.db_cur_key = but.stored_str
	global.db_key_v = but.stored_str
	but_tar = but
	but_tar_reset = 1
	but.toggle_mode = 1
	global.ani_selected = but.stored_str
	#directory_refresh()
	ItemDisplay.display_refresh()

func _on_LineSearch_updated(text):
	directory_filter()

