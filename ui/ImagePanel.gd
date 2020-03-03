extends PanelContainer
onready var Popups = get_node("..")

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed and not event.is_echo():
		visible = 0
		Popups.visible = 0
