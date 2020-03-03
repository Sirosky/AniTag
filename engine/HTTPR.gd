extends HTTPRequest

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var anidb_id = 239
var anidb_api_url = "http://api.anidb.net:9001/httpapi?request=anime&client=xbmcscrap&clientver=1&protover=1&aid="
var down_path = "user://db/"

# Called when the node enters the scene tree for the first time.
func _ready():
	#anidb_update()
	pass # Replace with function body.

func confirm():
	print("Hi")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
