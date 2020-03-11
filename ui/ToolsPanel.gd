extends TabContainer

var mode_bulk = 0 #Whether we're processing bulk jobs
onready var Popups = get_node("/root/Main/Popups")
onready var LibManager = get_node("/root/Main/Library/LibraryManager")

onready var DirConfirm = get_node("Rename Directories/VBoxContainer/HBoxContainer/ButConfirm")
onready var DirDisplayed = get_node("Rename Directories/VBoxContainer/CheckBoxDisplayed")
onready var DirDisplayed2 = get_node("Rename Directories/VBoxContainer/CheckBoxDisplayed2")
onready var DirDisplayed3 = get_node("Rename Directories/VBoxContainer/CheckBoxDisplayed3")
onready var DirGroup = DirDisplayed.group
onready var DirCancel = get_node("Rename Directories/VBoxContainer/HBoxContainer/ButCancel")
onready var DirLabel = get_node("Rename Directories/VBoxContainer/Label")

onready var EntryConfirm = get_node("Rename Entries/VBoxContainer/HBoxContainer/ButConfirm")
onready var EntryDisplayed2 = get_node("Rename Entries/VBoxContainer/CheckBoxDisplayed2")
onready var EntryDisplayed3 = get_node("Rename Entries/VBoxContainer/CheckBoxDisplayed3")
onready var EntryGroup = EntryDisplayed2.group
onready var EntryCancel = get_node("Rename Entries/VBoxContainer/HBoxContainer/ButCancel")
onready var EntryLabel = get_node("Rename Entries/VBoxContainer/Label")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	DirConfirm.connect("pressed",self,"_on_DirConfirm_pressed")
	DirCancel.connect("pressed",self,"_on_ButCancel_pressed")
	
	EntryConfirm.connect("pressed",self,"_on_EntryConfirm_pressed")
	EntryCancel.connect("pressed",self,"_on_ButCancel_pressed")
	
func labels_refresh(): #Refreshes between bulk/ non-bulk descriptions
	if mode_bulk == 1:
		DirLabel.text = "[Bulk Mode] This tool renames the folders of each library entry according to their AniDB name."
		EntryLabel.text = "[Bulk Mode] This tool renames each entry according to their AniDB name."
	else:
		DirLabel.text = "This tool renames the folders of the selected entry according to their AniDB ID."
		EntryLabel.text = "This tool renames the selected entry according to its AniDB name."


func _on_DirConfirm_pressed():
	
	if DirGroup.get_pressed_button() == DirDisplayed:
		LibManager.mode_name = 0
	if DirGroup.get_pressed_button() == DirDisplayed2:
		LibManager.mode_name = 1
	if DirGroup.get_pressed_button() == DirDisplayed3:
		LibManager.mode_name = 2
	
	visible = 0
	Popups.visible = 0
	
	LibManager.mode_bulk = mode_bulk
	if mode_bulk ==1:
		LibManager.dir_rename_bulk()
	else:
		LibManager.dir_rename(global.db_key_v)
	
func _on_EntryConfirm_pressed():
	
	if EntryGroup.get_pressed_button() == EntryDisplayed2:
		LibManager.mode_name = 1
	if EntryGroup.get_pressed_button() == EntryDisplayed3:
		LibManager.mode_name = 2
	
	print(LibManager.mode_name)
	visible = 0
	Popups.visible = 0
	
	LibManager.mode_bulk = mode_bulk
	if mode_bulk == 1:
		LibManager.entry_rename_bulk()
	else:
		LibManager.entry_rename(global.db_key_v)

func _on_ButCancel_pressed():
	visible = 0
	Popups.visible = 0
