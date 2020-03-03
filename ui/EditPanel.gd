extends PanelContainer

onready var Popups = get_node("/root/Main/Popups")
onready var ItemDisplay = get_node("/root/Main/HBoxContainer/ItemDisplay")

onready var ButAccept = get_node("/root/Main/Popups/EditPanel/VBoxContainer/HBoxBut/ButAccept")
onready var ButCancel = get_node("/root/Main/Popups/EditPanel/VBoxContainer/HBoxBut/ButCancel")
onready var ButSearch = get_node("VBoxContainer/GridContainer/ButSearch")
onready var ButSearchID = get_node("VBoxContainer/GridContainer/ButSearchID")

onready var LineNameDisp = get_node("/root/Main/Popups/EditPanel/VBoxContainer/GridContainer/LineName")
onready var LineAniDBName = get_node("/root/Main/Popups/EditPanel/VBoxContainer/GridContainer/LineAniDBName")
onready var LineID = get_node("/root/Main/Popups/EditPanel/VBoxContainer/GridContainer/LineID")
onready var LinePath = get_node("/root/Main/Popups/EditPanel/VBoxContainer/GridContainer/LinePath")
onready var TextDesc = get_node("/root/Main/Popups/EditPanel/VBoxContainer/GridContainer/TextDesc")

#global.db[global.db_cur_key]["name_displayed"]

func _ready():
	ButSearch.connect("pressed",self,"_on_ButSearch_pressed")
	ButSearchID.connect("pressed",self,"_on_ButSearchID_pressed")
	ButAccept.connect("pressed",self,"_on_ButAccept_pressed")
	ButCancel.connect("pressed",self,"_on_ButCancel_pressed")

func update():
	LineNameDisp.text = global.db[global.db_cur_key]["name"]
	LineAniDBName.text = global.db[global.db_cur_key]["anidb_name"]
	LineID.text = str(global.db[global.db_cur_key]["id"])
	LinePath.text = str(global.db[global.db_cur_key]["path"])
	if str(global.db[global.db_cur_key]["description"]) == "":
		TextDesc.text = str(global.db[global.db_cur_key]["anidb_description"])
	else:
		TextDesc.text = str(global.db[global.db_cur_key]["description"])

func _on_ButSearch_pressed():
	OS.shell_open(str("https://anidb.net/search/anime/?adb.search="+str(global.db[global.db_key_v]["anidb_name"])+"&do.search=1"))

func _on_ButSearchID_pressed():
	OS.shell_open(str("https://anidb.net/anime/"+str(global.db[global.db_key_v]["id"])))

func _on_ButAccept_pressed():
	global.db[global.db_cur_key]["id"] = str(LineID.text)
	global.db[global.db_cur_key]["name"] = str(LineNameDisp.text)
	global.db[global.db_cur_key]["anidb_name"] = str(LineAniDBName.text)
	global.db[global.db_cur_key]["path"] = str(LinePath.text)
	global.db[global.db_cur_key]["description"] = str(TextDesc.text)
	
	global.Mes.message_send("Metadata updated.")
	global.json_write("user://db/"+global.db_name,global.db)
	visible = 0
	Popups.visible = 0
	get_node("../").visible = 0
	ItemDisplay.display_refresh()
	
func _on_ButCancel_pressed():
	visible = 0
	Popups.visible = 0
	get_node("../").visible = 0
	
