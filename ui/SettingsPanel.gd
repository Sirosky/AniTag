extends PanelContainer

onready var Popups = get_node("..")
onready var ButAccept = get_node("VBoxContainer/HBoxBut/ButAccept")
onready var ButCancel = get_node("VBoxContainer/HBoxBut/ButCancel")

onready var CheckLoad = get_node("VBoxContainer/GridContainer/CheckLoad")
onready var CheckError = get_node("VBoxContainer/GridContainer/CheckError")
onready var CheckFullscreen = get_node("VBoxContainer/GridContainer/CheckFullscreen")

func _ready():
	ButAccept.connect("pressed",self,"_on_ButAccept_pressed")
	ButCancel.connect("pressed",self,"_on_ButCancel_pressed")

func init():
	CheckLoad.pressed = global.settings["General"]["autoload"]
	CheckError.pressed = global.settings["General"]["error"]
	CheckFullscreen.pressed = global.settings["General"]["fullscreen"]

func _on_ButAccept_pressed():
	Popups.visible = 0
	visible = 0
	global.settings["General"]["autoload"] = CheckLoad.pressed
	global.settings["General"]["error"] = CheckError.pressed
	global.settings["General"]["fullscreen"] = CheckFullscreen.pressed
	global.json_write(global.settings_path, global.settings)
	global.window_manage()
	global.Mes.message_send("Settings saved")

func _on_ButCancel_pressed():
	Popups.visible = 0
	visible = 0
