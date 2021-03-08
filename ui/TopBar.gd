extends PanelContainer

onready var ViewListItem = get_node("/root/Main/HBoxContainer/Panel/LeftDisplay/ViewListItem")

onready var ButLoad = get_node("TopBarHBox/ButLoad")
onready var ButBuild = get_node("TopBarHBox/ButBuild")
onready var ButRefresh = get_node("TopBarHBox/ButRefresh")
onready var ButRandom = get_node("TopBarHBox/ButRandom")
onready var ButList = get_node("TopBarHBox/ButList")
onready var ButBulkThumb = get_node("TopBarHBox/ButBulkThumb")
onready var ButBulkUpdate = get_node("TopBarHBox/ButBulkUpdate")
onready var ButMore = get_node("TopBarHBox/ButMore")
onready var ButSettings = get_node("TopBarHBox/ButSettings")
onready var ButFilter = get_node("../HBoxFilter/ButFilter")

onready var FileDiag = get_node("/root/Main/Popups/FileDialog") 
onready var LibBuilder = get_node("../../../../Library/LibraryBuilder")
onready var LibLoader = get_node("../../../../Library/LibraryLoader")
onready var LibThumb = get_node("../../../../Library/LibraryThumb")
onready var LibUpdater = get_node("../../../../Library/LibraryUpdater")
onready var LibManager = get_node("/root/Main/Library/LibraryManager")

onready var Popups = get_node("/root/Main/Popups") 
onready var PopPanel = get_node("../../../../Popups/PopPanel")
onready var PopText = get_node("../../../../Popups/PopPanel/PopText")
onready var PopTag = get_node("/root/Main/Popups/TagPanel")
onready var ConfirmPanel = get_node("/root/Main/Popups/ConfirmPanel")
onready var SettingsPanel = get_node("/root/Main/Popups/SettingsPanel")
onready var ToolsPanel = get_node("/root/Main/Popups/ToolsPanel")
onready var ButConfirm = get_node("/root/Main/Popups/ConfirmPanel/VBoxContainer/HBoxContainer/ButConfirm")
onready var ButCancel = get_node("/root/Main/Popups/ConfirmPanel/VBoxContainer/HBoxContainer/ButCancel")
onready var ButAccept = get_node("../../../../Popups/PopPanel/PopText/ButAccept")
onready var TextEd = get_node("../../../../Popups/PopPanel/PopText/LineEdit")


func _ready():
	
	ButLoad.connect("pressed",self,"_on_ButLoad_pressed")
	ButLoad.hint_tooltip = "Load a library"
	
	ButBuild.connect("pressed",self,"_on_ButBuild_pressed")
	ButBuild.hint_tooltip = "Build a library"
	
	ButRefresh.connect("pressed",self,"_on_ButRefresh_pressed")
	ButRefresh.hint_tooltip = "Rescan current library"
	
	ButRandom.connect("pressed",self,"_on_ButRandom_pressed")
	ButRandom.hint_tooltip = "Randomize"
	
	ButList.connect("pressed",self,"_on_ButList_pressed")
	ButList.hint_tooltip = "Update AniDB List"
	
	ButBulkThumb.connect("pressed",self,"_on_ButBulkThumb_pressed")
	ButBulkThumb.hint_tooltip = "Bulk generate thumbnails"
	
	ButBulkUpdate.connect("pressed",self,"_on_ButBulkUpdate_pressed")
	ButBulkUpdate.hint_tooltip = "Bulk update shows"
	
	ButFilter.connect("pressed",self,"_on_ButFilter_pressed")
	ButFilter.hint_tooltip = "Apply filter based on tags"
	
	ButMore.connect("pressed",self,"_on_ButMore_pressed")
	ButMore.hint_tooltip = "More tools"
	
	ButSettings.connect("pressed",self,"_on_ButSettings_pressed")
	ButSettings.hint_tooltip = "Change AniTag settings"
	
	ButAccept.connect("pressed",self,"_on_ButAccept_pressed")
	
	FileDiag.connect("confirmed",self,"_on_confirmed")
	FileDiag.connect("file_selected",self,"_on_file_selected")
	
	#For confirm panel
	ButConfirm.connect("pressed",self,"_on_ButConfirm_pressed")
	ButCancel.connect("pressed",self,"_on_ButCancel_pressed")


func _on_ButLoad_pressed():
	FileDiag.mode = 0 #Open file mode
	FileDiag.access = 1 #Allow accessing only users
	FileDiag.current_dir = ProjectSettings.globalize_path("user://db")
	FileDiag.popup()
	
func _on_ButBuild_pressed(): #Get name first of new library
	Popups.visible = 1
	PopPanel.visible = 1
	PopText.visible = 1
	PopPanel.mode = 0
	
func _on_ButRefresh_pressed():
	global.dir_path = global.db["_Settings"]["main_path"]
	LibBuilder.refreshing = 1
	LibBuilder.library_build_init()
	print(global.dir_path)
	
func _on_ButRandom_pressed():
	if global.db.size() > 0:
		randomize()
		
		var filter_size = ViewListItem.but_index_filtered.size()
		if filter_size > 0: #Only randomize from filtered
			var ran = round(rand_range(0,filter_size-1))
			global.Mes.message_send("Rolled " + str(ran+1) + " out of " + str(filter_size))
			ViewListItem.but_index_filtered[ran].emit_signal("pressed")
		else: #No filter applied
			var ran = round(rand_range(0,global.db.size()-2)) #it's -2 because of _Settings
			global.Mes.message_send("Rolled " + str(ran+1) + " out of " + str(global.db.size()-1))
			var keys = global.db.keys()
			var key_index = keys[ran]
			ViewListItem.but_index[ran].emit_signal("pressed") #Load the first selection
		#OS.shell_open(global.db[key_index]["path"])
	
func _on_ButAccept_pressed(): #Open dialog to select new directory
	if PopPanel.mode == 0:
		PopText.visible = 0
		PopPanel.visible = 0
		Popups.visible = 0
		global.db_name = str(TextEd.text+".json")
		FileDiag.mode = 2 #Open dir mode
		FileDiag.access = 2 #Allow accessing whole file system
		ProjectSettings.globalize_path("res://")
		FileDiag.popup()
	
func _on_ButFilter_pressed():
	Popups.visible = 1
	PopTag.visible = 1
	PopTag.top_refresh()
	
func _on_ButList_pressed():
	LibUpdater.anidb_list_update()
	
func _on_ButBulkThumb_pressed():
	LibThumb.thumbs_generate_bulk()
	
func _on_ButBulkUpdate_pressed():
	LibUpdater.bulk_update()

func _on_ButMore_pressed():
	Popups.visible = 1
	ToolsPanel.visible = 1
	ToolsPanel.mode_bulk = 1
	ToolsPanel.labels_refresh()
	#ConfirmPanel.visible = 1
	#ConfirmPanel.mode = 2
	#ConfirmPanel.get_node("VBoxContainer/MarginContainer/Label").text = "This renames a number of directories according to their AniDB name."

func _on_ButSettings_pressed():
	Popups.visible = 1
	SettingsPanel.visible = 1
	SettingsPanel.init()

func _on_ButConfirm_pressed():
	if ConfirmPanel.mode == 2:
		LibManager.dir_rename_bulk()
		ConfirmPanel.mode = 0
		
	Popups.visible = 0
	ConfirmPanel.visible = 0

func _on_ButCancel_pressed():
	Popups.visible = 0
	ConfirmPanel.visible = 0

func _on_confirmed():
	
	if FileDiag.mode == 2: #Building a new library
		global.dir_path = FileDiag.current_path
		LibBuilder.library_build_init()
		
	if FileDiag.mode == 0: #Loading a local library
		global.db_path = str(FileDiag.current_path)
		LibLoader.library_load()
		#print(global.db_path)

func _on_file_selected(file):
	if FileDiag.mode == 0: #Building a new library
		global.db_path = str(FileDiag.current_path)
		LibLoader.library_load()
		#print(global.db_path)

