extends FileDialog

var signal_tar = "../HBoxContainer/ItemDisplay/VBoxContainer/Settings"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func init():
	#self.connect("dir_selected",get_node(signal_tar),"_on_dir_selected",[self]) #Connect to parent
	self.connect("confirmed",get_node(signal_tar),"_on_confirmed",[self]) #Connect to parent
	self.connect("file_selected",get_node(signal_tar),"_on_file_selected",[self]) #Connect to parent

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
