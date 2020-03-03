extends Button


var stored_int = 0
var stored_str = []
var signal_tar = "../.."

signal pressed_rmb
signal pressed_mmb

func _ready():
	#init()
	pass
	
func init():
	text = stored_str[0]
	
func _process(delta):
	#hint_tooltip = str(rect_size.x)
	pass
	
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and not event.is_echo():
		if event.button_index == BUTTON_RIGHT:
			emit_signal("pressed_rmb", self)
		if event.button_index == BUTTON_LEFT:
			emit_signal("pressed", self)
