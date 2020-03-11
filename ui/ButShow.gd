extends Button


var stored_int = 0
var stored_str = ""
var signal_tar = "../.."
var signal_method = "_on_ButShow_pressed"

func _ready():
	init()
	
	
func init():
	text = stored_str
	#self.connect("pressed",get_node(signal_tar),signal_method,[self]) #Connect to parent
	
