extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var window_size = OS.get_window_size()
	rect_size.x = window_size.x
	rect_size.y = window_size.y
