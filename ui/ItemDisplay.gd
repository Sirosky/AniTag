extends ScrollContainer
var file_search = FileSearch.new() #Launch file search class

onready var LibUpdater = get_node("../../Library/LibraryUpdater")
onready var LibThumb = get_node("/root/Main/Library/LibraryThumb")

onready var ButDir = get_node("VBoxContainer/TopHBox/ConfigVBox/ButDir")
onready var ButDB = get_node("VBoxContainer/TopHBox/ConfigVBox/ButDB")
onready var ButUpdate = get_node("VBoxContainer/TopHBox/ConfigVBox/ButUpdate")
onready var ButLink = get_node("VBoxContainer/TopHBox/ConfigVBox/ButLink")
onready var ButThumb = get_node("VBoxContainer/TopHBox/ConfigVBox/ButThumb")
onready var ButEdit = get_node("VBoxContainer/TopHBox/ConfigVBox/ButEdit")
onready var ButDelete = get_node("VBoxContainer/TopHBox/ConfigVBox/ButDelete")
onready var ButAccept = get_node("/root/Main/Popups/PopPanel/PopText/ButAccept")

#UI
onready var Title = get_node("VBoxContainer/TopHBox/VBoxContainer/Title")
onready var AirInt = get_node("VBoxContainer/TopHBox/VBoxContainer/InfoHBox/AirDate/AirInt")
onready var ScoreInt = get_node("VBoxContainer/TopHBox/VBoxContainer/InfoHBox/AnidbScore/ScoreInt")
onready var EpInt = get_node("VBoxContainer/TopHBox/VBoxContainer/InfoHBox/Episodes/EpInt")
onready var Desc = get_node("VBoxContainer/TopHBox/VBoxContainer/Panel/MarginContainer/Description")
onready var TagsCon = get_node("VBoxContainer/TagsCon")
onready var FilesVBox = get_node("/root/Main/HBoxContainer/ItemDisplay/VBoxContainer/FilesPanel/FilesVBox")
onready var FilesPanel = get_node("/root/Main/HBoxContainer/ItemDisplay/VBoxContainer/FilesPanel")
onready var TopHBox = get_node("/root/Main/HBoxContainer/ItemDisplay/VBoxContainer/TopHBox")
onready var ViewListItem = get_node("../Panel/LeftDisplay/ViewListItem")

#InfoBox UI
onready var InfoBox = get_node("VBoxContainer/InfoBox")
onready var PanelLeft = get_node("VBoxContainer/InfoBox/PanelLeft")
onready var PanelRight = get_node("VBoxContainer/InfoBox/PanelRight")
onready var RelatedGrid = get_node("VBoxContainer/InfoBox/PanelLeft/RelatedGrid")
onready var StaffGrid = get_node("VBoxContainer/InfoBox/PanelRight/StaffGrid")

#Popups
onready var Popups = get_node("../../Popups")
onready var EditPanel = get_node("../../Popups/EditPanel")
onready var ConfirmPanel = get_node("../../Popups/ConfirmPanel")
onready var ButConfirm = get_node("../../Popups/ConfirmPanel/VBoxContainer/HBoxContainer/ButConfirm")
onready var ButCancel = get_node("../../Popups/ConfirmPanel/VBoxContainer/HBoxContainer/ButCancel")
onready var PopPanel = get_node("/root/Main/Popups/PopPanel")
onready var LineEdit = get_node("/root/Main/Popups/PopPanel/PopText/LineEdit")

onready var Tween = get_node("/root/Main/Tween")

var but = preload("res://ui/ButTag.tscn")
var but_file = preload("res://ui/ButFile.tscn")
var info_label = preload("res://ui/InfoLabel.tscn")
var but_index= []
var but_file_index= []

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#Prepare buttons
	ButDir.connect("pressed",self,"_on_ButDir_pressed")
	ButDir.hint_tooltip = "Open directory"
	
	ButDB.connect("pressed",self,"_on_ButDB_pressed")
	ButDB.hint_tooltip = "Open database directory"
	
	ButUpdate.connect("pressed",self,"_on_ButUpdate_pressed")
	ButUpdate.hint_tooltip = "Update metadata from AniDB"
	
	ButLink.connect("pressed",self,"_on_ButLink_pressed")
	ButLink.hint_tooltip = "Open AniDB page"
	
	ButThumb.connect("pressed",self,"_on_ButThumb_pressed")
	ButThumb.hint_tooltip = "Generate thumbnails"
	
	ButEdit.connect("pressed",self,"_on_ButEdit_pressed")
	ButEdit.hint_tooltip = "Edit metadata"
	
	ButDelete.connect("pressed",self,"_on_ButDelete_pressed")
	ButDelete.hint_tooltip = "Delete library entry"
	
	#For ConfirmPanel
	ButConfirm.connect("pressed",self,"_on_ButConfirm_pressed")
	ButCancel.connect("pressed",self,"_on_ButCancel_pressed")
	
	#For TagPanel
	ButAccept.connect("pressed",self,"_on_ButAccept_pressed")
	
	#FilesVBox.sort_children()

func display_refresh():
	#Updates displayed metadata
	#print(str("Global cur key-"+global.db_key_v))
	
	if global.db.size() > 0 and global.db_key_v!="":
		#Reset everything
		TopHBox.modulate = Color(1, 1, 1, 0)
		FilesPanel.modulate = Color(1, 1, 1, 0)
		TagsCon.modulate = Color(1, 1, 1, 0)
		InfoBox.modulate = Color(1, 1, 1, 0)
		LibThumb.job_continue = 0
		LibThumb.job_index = 0
		LibThumb.job_timer = 0
		LibThumb.ThumbsCon.visible = 0
		
		Title.text = str(global.db[global.db_key_v]["name"])
		AirInt.text = str(global.db[global.db_key_v]["date"])
		ScoreInt.text = str(global.db[global.db_key_v]["anidb_score"])
		EpInt.text = str(global.db[global.db_key_v]["episodes"])
		if global.db[global.db_key_v]["description"] == "":
			Desc.bbcode_text = str(global.db[global.db_key_v]["anidb_description"])
		else:
			Desc.bbcode_text = str(global.db[global.db_key_v]["description"])
		LibUpdater.anidb_refresh_cover(int(global.db[global.db_key_v]["id"]))
		Tween.interpolate_property(TopHBox, "modulate",Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1, Tween.TRANS_SINE, Tween.EASE_OUT)
		Tween.start()
		
		#TAGS
		yield(get_tree().create_timer(.1), "timeout")
		display_refresh_tags()
		Tween.interpolate_property(TagsCon, "modulate",Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1, Tween.TRANS_SINE, Tween.EASE_OUT)
		Tween.start()
			
		#FILES section	
		yield(get_tree().create_timer(.1), "timeout")
		
		if global.db_key_v!="": #Load files we have in directory
			
			if !FilesPanel.visible:
				FilesPanel.visible = 1
		
			global.children_delete(FilesVBox)
			var search = file_search.search_regex_full_path(global.filter_vid_regex, global.db[global.db_key_v]["path"], 0) #Make sure this dir actually has videos
			
			for i in search.keys():
				var temp=but_file.instance()
				FilesVBox.add_child(temp) #load button into the right container
				var node_path = NodePath(get_path_to(temp)) #locate the newly created button
				temp = get_node(node_path) #get button
				
				temp.stored_str.append(i)
				temp.text = str(i.get_file())
				#print(str(i)+":"+str(search[i]))
				
				if !temp.is_connected("pressed", self, "_on_ButFile_pressed"):
					temp.connect("pressed", self, "_on_ButFile_pressed", [temp])
			
			if search.size()>0: 
				var win_size = OS.get_window_size()
				FilesVBox.sort_children("Button", win_size.x-rect_position.x-24, 3)
				Tween.interpolate_property(FilesPanel, "modulate",Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1, Tween.TRANS_SINE, Tween.EASE_OUT)
				Tween.start()
			else: #No video files found, hide panel
				FilesPanel.visible = 0
			
			
			#THUMBS
			yield(get_tree().create_timer(.1), "timeout")
			LibThumb.thumbs_refresh()
		
		#RELATED section
		
		yield(get_tree().create_timer(.1), "timeout")
		if global.db[global.db_key_v]["related"].size()>0: #Make sure array actually has stuff
			global.children_delete(RelatedGrid)
			for i in global.db[global.db_key_v]["related"]:
				var temp=info_label.instance()
				RelatedGrid.add_child(temp) #load button into the right container
				var node_path = NodePath(get_path_to(temp)) #locate the newly created button
				temp = get_node(node_path) #get button
				
				var name = LibUpdater.masterdb_get_name(i)
				temp.text = str(global.db[global.db_key_v]["related"][i]+": "+str(name))
		else:
			global.children_delete(RelatedGrid)
			var temp=info_label.instance()
			RelatedGrid.add_child(temp) #load button into the right container
			var node_path = NodePath(get_path_to(temp)) #locate the newly created button
			temp = get_node(node_path) #get button
			
			temp.text = "No related anime found :("
		
		#STAFF section
		if global.db[global.db_key_v]["staff"].size()>0: #Make sure array actually has stuff
			global.children_delete(StaffGrid)
			for i in global.db[global.db_key_v]["staff"]:
				var temp=info_label.instance()
				StaffGrid.add_child(temp) #load button into the right container
				var node_path = NodePath(get_path_to(temp)) #locate the newly created button
				temp = get_node(node_path) #get button
				
				temp.text = str(str(i)+": "+global.db[global.db_key_v]["staff"][i])
		else:
			global.children_delete(StaffGrid)
			var temp=info_label.instance()
			StaffGrid.add_child(temp) #load button into the right container
			var node_path = NodePath(get_path_to(temp)) #locate the newly created button
			temp = get_node(node_path) #get button
			
			temp.text = "No staff found :("
		#yield(get_tree(), "idle_frame") #Smooth out loading a bit
		
		Tween.interpolate_property(InfoBox, "modulate",Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1, Tween.TRANS_SINE, Tween.EASE_OUT)
		Tween.start()


func display_refresh_tags():
	#TAGS section- only called from display_refresh.
	if global.db[global.db_key_v]["anidb_tags"].size()>0: #Make sure array actually has stuff
		global.children_delete(TagsCon)
		TagsCon.visible = 0
		#TagsCon.x_size = TagsCon.rect_size.x
		if !TagsCon.visible:
			TagsCon.visible = 1
		
		var combined_tags = global.db[global.db_key_v]["anidb_tags"]
		
		for i in global.db[global.db_key_v]["tags_user"]: #Add in user tags
			combined_tags.append(i)
		
		for i in combined_tags: #Loop through tags
			if global.db[global.db_key_v]["tags_hidden"].find(i) == -1 and global.settings["General"]["tags_hidden"].find(i) == -1: #Only create non-excluded tags
				var temp=but.instance()
				TagsCon.add_child(temp) #load button into the right container
				var node_path = NodePath(get_path_to(temp)) #locate the newly created button
				temp = get_node(node_path) #get button
				
				temp.stored_str.append(i)
				if !temp.is_connected("pressed", self, "_on_ButTag_pressed"):
					temp.connect("pressed", self, "_on_ButTag_pressed", [temp])
				
				if !temp.is_connected("pressed_rmb", self, "_on_ButTag_pressed_rmb"):
					temp.connect("pressed_rmb", self, "_on_ButTag_pressed_rmb")
				temp.text = str(i) #update text label
				but_index.append(temp) #add this into our button array
				
		#Add in + tag button
		var temp=but.instance()
		TagsCon.add_child(temp) #load button into the right container
		var node_path = NodePath(get_path_to(temp)) #locate the newly created button
		temp = get_node(node_path) #get button
		
		temp.stored_str.append("+")
		if !temp.is_connected("pressed", self, "_on_ButTag_pressed"):
			temp.connect("pressed", self, "_on_ButTag_pressed", [temp])
		
		if !temp.is_connected("pressed_rmb", self, "_on_ButTag_pressed_rmb"):
			temp.connect("pressed_rmb", self, "_on_ButTag_pressed_rmb")
		temp.text = str("+") #update text label
		but_index.append(temp) #add this into our button array
		
		#Final sorting
		var win_size = OS.get_window_size()
		TagsCon.sort_children("Button", win_size.x-rect_position.x-12, 3)
	else:
		TagsCon.visible = 0 #Hide all tag related stuff if there aren't any tags
	


func _on_ButDir_pressed():
	if global.db_key_v!="":
		OS.shell_open(global.db[global.db_key_v]["path"])
		
func _on_ButDB_pressed():
	if global.db.size()>0:
		if int(global.db[global.db_key_v]["id"])>-1:
			var ani_id = global.db[global.db_key_v]["id"]
			OS.shell_open(ProjectSettings.globalize_path("user://db/anidb/"+str(ani_id)))

func _on_ButUpdate_pressed():
	if global.db.size()>0 and global.ani_selected!="":
		LibUpdater.anidb_init(global.ani_selected)
	
func _on_ButLink_pressed():
	if global.db.size()>0:
		if int(global.db[global.db_key_v]["id"])>-1: #We know the show
			OS.shell_open(str("https://anidb.net/anime/"+str(global.db[global.db_key_v]["id"])))
		else: #We don't know the show, search for it
			OS.shell_open(str("https://anidb.net/search/anime/?adb.search="+str(global.db[global.db_key_v]["anidb_name"])+"&do.search=1"))

func _on_ButTag_pressed(but):
	if but.stored_str[0] == "+": #Add new tag button
		PopPanel.mode = 1
		PopPanel.visible = 1
		Popups.visible = 1

func _on_ButTag_pressed_rmb(but): #Universally hide tag
	var tar_tag = but.stored_str[0]
	
	if global.settings["General"]["tags_hidden"].find(tar_tag) == -1: #Tag hasn't been added before
		but.visible = 0
		global.Mes.message_send("Tag " + str(tar_tag) + " globally hidden.")
		global.settings["General"]["tags_hidden"].append(tar_tag)
		global.json_write(global.settings_path, global.settings)

func _on_ButFile_pressed(but):
	#print(but.stored_str[0])
	
	var file_temp = File.new() #Verify file rename succeeded
	
	if file_temp.file_exists(str(but.stored_str[0])):
		OS.shell_open(but.stored_str[0])
	else:
		print(str("File doesn't exist." + but.stored_str[0]))
	
func _on_ButThumb_pressed():
	LibThumb.thumbs_generate()
	
func _on_ButEdit_pressed():
	EditPanel.update()
	EditPanel.visible = 1
	Popups.visible = 1

func _on_ButDelete_pressed():
	Popups.visible = 1
	ConfirmPanel.visible = 1
	ConfirmPanel.mode = 1
	ConfirmPanel.get_node("VBoxContainer/MarginContainer/Label").text = "This will delete the library entry permanently."

func _on_ButConfirm_pressed():
	if ConfirmPanel.mode == 1:
		global.Mes.message_send(str(global.db[global.db_key_v]["name"]) + " deleted.")
		global.db.erase(global.db_key_v)
		global.json_write("user://db/"+global.db_name,global.db)
		ConfirmPanel.mode = 0
		ViewListItem.directory_refresh()
		
	Popups.visible = 0
	ConfirmPanel.visible = 0

func _on_ButCancel_pressed():
	Popups.visible = 0
	ConfirmPanel.visible = 0
	
func _on_ButAccept_pressed(): #Add custom tag
	if PopPanel.mode == 1:
		if global.db.has(global.db_key_v) and LineEdit.text != "":
			global.db[global.db_key_v]["tags_user"].append(LineEdit.text)
			global.Mes.message_send("Tag " + str(LineEdit.text) + " added.")
	
	PopPanel.visible = 0
	Popups.visible = 0
	global.json_write("user://db/"+global.db_name,global.db)
