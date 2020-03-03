extends Node

onready var Message = preload("res://ui/messenger/Message.tscn")
onready var Tween = get_node("/root/Main/Tween") #This is a dependency.

var message_queue: Array #Current displayed messages
var message_gap = 16 #Space between messages
var message_max = 3 #Max number of messages
var message_count = 0 #Current number of messages
var message_life = 150 #How long they should stay
var message_timer_arr: Array #Holds timer info for all messages
var message_alpha = .8 #Maximum alpha value

var screen_size = OS.get_screen_size()
onready var window_width = screen_size.x
onready var window_height = screen_size.y

func _ready():
	Tween.connect("tween_completed", self,"_on_tween_completed")

func message_send(text):
	
	var temp = Message.instance()
	add_child(temp) #load button into the right container
	var node_path = NodePath(get_path_to(temp)) #locate the newly created button
	temp = get_node(node_path) #get button
	
	var tween_dur = 1
	temp.rect_position.x = window_width - temp.rect_size.x - 1
	temp.rect_position.y = window_height + 16
	temp.modulate = Color(1, 1, 1, 0)	
	message_queue.push_front(temp)
	temp.connect("destroy_me", self,"message_delete", [temp])
	temp.time = message_life
	temp.countdown_initial = tween_dur * 60
	temp.text = str(text)
	temp.init()
	
	var tar_x = temp.rect_position.x
	var tar_y = window_height - temp.rect_size.y - message_gap
	
	message_sort()
	Tween.interpolate_property(temp, "modulate",Color(1, 1, 1, 0), Color(1, 1, 1, message_alpha), tween_dur, Tween.TRANS_SINE, Tween.EASE_OUT)
	Tween.interpolate_property(temp, "rect_position", Vector2(temp.rect_position.x, temp.rect_position.y), Vector2(tar_x,tar_y), tween_dur, Tween.TRANS_SINE, Tween.EASE_OUT)
	Tween.start()

func message_sort():
	
	for i in message_queue:
		var index = message_queue.find(i)
		var size = message_queue.size()
		
		if index != 0:
		
			var tar_x = i.rect_position.x
			var tar_y = window_height - ((i.rect_size.y + message_gap) * (index + 1))
			
			Tween.interpolate_property(i, "rect_position", Vector2(i.rect_position.x, i.rect_position.y), Vector2(tar_x,tar_y), 1.5, Tween.TRANS_SINE, Tween.EASE_OUT)
			Tween.start()

func message_delete(message):
	var tween_dur = .5
	message.countdown_destruction = 60 * tween_dur
	message_queue.remove(message_queue.find(message))
	Tween.interpolate_property(message, "modulate",Color(1, 1, 1, message_alpha), Color(1, 1, 1, 0), tween_dur, Tween.TRANS_SINE, Tween.EASE_OUT)
	Tween.start()

func _on_tween_completed(obj, node):
	pass
	#Can figure out how this works later
	#print(obj)
	#print(node)
