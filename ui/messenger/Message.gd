extends PanelContainer

var time: int
var text = ''
var countdown_initial = -1 #Countdown before actual timer starts
var countdown_destruction = -1 #Destroy once this hits 0 
var destroy_emitted = 0 #Destroy signal emitted

signal destroy_me

onready var Bar = get_node("HBoxContainer/ProgressBar")

# Called when the node enters the scene tree for the first time.
func init():
	get_node("HBoxContainer/MarginContainer/RichTextLabel").bbcode_text = text
	get_node("HBoxContainer/ProgressBar").max_value = time
	Bar.value = time

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if time <= 0 and destroy_emitted == 0:
		emit_signal("destroy_me")
		destroy_emitted = 1
	elif countdown_initial <= 0:
		time -= 1
		Bar.value = time
	
	if countdown_destruction > 0:
		countdown_destruction -= 1
		
	if countdown_initial > 0:
		countdown_initial -= 1
	
	if countdown_destruction == 0:
		queue_free()
		
	
	
	
	
