extends HBoxContainer
"""
onready var FileDiag = get_node("../../../../FileDialog") 
onready var LibBuilder = get_node("../../../../Library/LibraryBuilder")
onready var LibLoader = get_node("../../../../Library/LibraryLoader")

onready var HBoxText = get_node("../HBoxText")
onready var ButAccept = get_node("../HBoxText/ButAccept")
onready var TextEd = get_node("../HBoxText/LineEdit")



func _ready():
	ButAccept.connect("pressed", self, "_on_ButAccept_pressed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BuildLocalLibrary_pressed():
	HBoxText.visible = 1
	


func _on_LoadLocalLibrary_pressed():
	FileDiag.mode = 0 #Open file mode
	FileDiag.access = 0 #Allow accessing only resources
	FileDiag.popup()

func _on_ButAccept_pressed():
	HBoxText.visible = 0
	global.db_name = str(TextEd.text+".json")
	FileDiag.mode = 2 #Open dir mode
	FileDiag.access = 2 #Allow accessing whole file system
	FileDiag.popup()

func _on_confirmed(diag):
	
	if diag.mode == 2: #Building a new library
		global.dir_path = diag.current_path
		LibBuilder.library_build()
		
	if diag.mode == 0: #Loading a local library
		global.db_path = str(diag.current_path)
		LibLoader.library_load()
		#print(global.db_path)

func _on_file_selected(file, diag):
	if diag.mode == 0: #Building a new library
		global.db_path = str(diag.current_path)
		LibLoader.library_load()
		#print(global.db_path)

"""
