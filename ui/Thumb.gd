extends TextureRect

onready var Popups = get_node("/root/Main/Popups") 
onready var ImagePanel = get_node("/root/Main/Popups/ImagePanel")
onready var ThumbLarge = get_node("/root/Main/Popups/ImagePanel/ThumbLarge")
var stored_str = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#self.connect("mouse_entered", self, "_on_mouse_entered")
	#self.connect("mouse_exited", self, "_on_mouse_exited")
#"""	
func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed and not event.is_echo():
		
		var x_size = rect_size.x*3
		var y_size = rect_size.y*3
		var ratio = x_size/y_size
		ImagePanel.visible = 1
		ThumbLarge.visible = 1
		Popups.visible = 1
	
		var image = Image.new()
		image.load(ProjectSettings.globalize_path(stored_str[0]))
		var tex = ImageTexture.new()
		
		tex.create_from_image(image,7)
		ThumbLarge.texture = tex
		
		if x_size>(OS.get_window_size().x*.8):
			x_size = OS.get_window_size().x*.8
			y_size = x_size/ratio
		#print(x_size)
		#print(OS.get_window_size().x)
		ImagePanel.rect_position.x = (OS.get_window_size().x/2) - (x_size/2)
		ImagePanel.rect_position.y = (OS.get_window_size().y/2) - (y_size/2)
		ThumbLarge.rect_min_size.x = x_size
		#ThumbLarge.rect_min_size.y = y_size
		ImagePanel.rect_min_size.x = x_size
		ImagePanel.rect_min_size.y = y_size
		#print(ThumbLarge.rect_min_size.x)
#"""	
		
func _on_mouse_entered():
	var x_size = rect_size.x*5
	var y_size = rect_size.y*5
	var ratio = x_size/y_size
	ImagePanel.visible = 1
	ThumbLarge.visible = 1
	Popups.visible = 1

	var image = Image.new()
	image.load(ProjectSettings.globalize_path(stored_str[0]))
	var tex = ImageTexture.new()
	
	tex.create_from_image(image,7)
	ThumbLarge.texture = tex
	
	if x_size>(OS.get_window_size().x*.8):
		x_size = OS.get_window_size().x*.8
		y_size = x_size/ratio
	#print(x_size)
	#print(OS.get_window_size().x)
	ImagePanel.rect_position.x = (OS.get_window_size().x/2) - (x_size/2)
	ImagePanel.rect_position.y = (OS.get_window_size().y/2) - (y_size/2)
	ThumbLarge.rect_min_size.x = x_size
	#ThumbLarge.rect_min_size.y = y_size
	ImagePanel.rect_min_size.x = x_size
	ImagePanel.rect_min_size.y = y_size
	#print(ThumbLarge.rect_min_size.x)

func _on_mouse_exited():
	ImagePanel.visible = 0
	ThumbLarge.visible = 0
	Popups.visible = 0
