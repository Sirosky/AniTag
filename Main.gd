extends Control

var directory = ""

var file_search = FileSearch.new() #Launch file search class
onready var HBox = get_node("HBoxContainer")

onready var LibraryLoader = get_node("Library/LibraryLoader")


func _ready():
	"""
	#How to use FFMPEG
	var ffmepg_path = ProjectSettings.globalize_path("res://db/thumbs/ffmpeg.exe")
	var output_path = ProjectSettings.globalize_path("res://db/thumbs/")
	var tar_path = 'D:/Sirosky/Sample.mkv'
	
	OS.execute(ffmepg_path, ["-i",tar_path,"-vf","fps=1/300",str(output_path+"thumb%04d.jpg"),"-hide_banner"], 0)
	
	#Load image from outside resources
	
	var image = Image.new()
	var err = image.load("D:/Sirosky/Watching/H/[I] MB/Waver/thumb0003.jpg")
	
	var texture = ImageTexture.new()
	texture.create_from_image(image,7)
	get_node("BG").texture = texture
	
	
	var dirtemp= Directory.new()
	print(dirtemp.rename("res://db1.zip","res://db2.zip"))
	"""
	#OS.set_window_size(Vector2( 1920, 1080 ))
	#print(ProjectSettings.globalize_path("user://"))
	
	var dir = Directory.new()  
	if dir.dir_exists("user://db") == false: #Make sure db folder exists
		dir.make_dir("user://db")
	if dir.dir_exists("user://db/anidb") == false: #Make sure anidb folder exists
		dir.make_dir("user://db/anidb")
	
	LibraryLoader.settings_load()
	#ProjectSettings.set_setting("display/window/size/width", global.screen_size.x);
	#ProjectSettings.set_setting("display/window/size/height", global.screen_size.y);
	#ProjectSettings.save();
	#Automatically resize as needed
	OS.window_size = (Vector2(global.screen_size.x,global.screen_size.y))
	#OS.set_window_position(Vector2(1280, 0))
	
func _process(_delta):
	
	var window_size = OS.get_window_size()
	HBox.rect_size.x = window_size.x
	HBox.rect_size.y = window_size.y
	"""
	"""
	
	"""
	var size = 0
	var current = 0
	if $HTTPR.get_body_size() != -1:
		size = $HTTPR.get_body_size()
		current = $HTTPR.get_downloaded_bytes()
		#$ProgressBar.value = current*100/size
		"""

func directory_list_folder(path): #list folders in the directory
	var files = [] # create array to hold files
	var folders = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		#print(str(file.get_extension()))
		
		if file == "": #last file already reached, leave loop
			break
		elif  file.get_extension() == "": #check if it is a folder, then add
			files.append(file)
	return files

#Input handler, listen for ESC to exit app
func _input(event):
	if event is InputEventKey and event.scancode == KEY_ESCAPE:
		get_tree().quit() 

#func _input(event):
	# Mouse in viewport coordinates
	#if event is InputEventMouseButton:
	#	print("Mouse Click/Unclick at: ", event.position)
	#elif event is InputEventMouseMotion:
	#	print("Mouse Motion at: ", event.position)

