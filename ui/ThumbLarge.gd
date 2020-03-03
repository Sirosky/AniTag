extends TextureRect
onready var ImagePanel = get_node("..")

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed and not event.is_echo():
		print(rect_size.x)
		#print(ImagePanel.rect_size.x)
		visible = 0
		ImagePanel.visible = 0
