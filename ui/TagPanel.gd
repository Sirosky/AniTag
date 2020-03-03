extends PanelContainer

var ButTagFilter = preload("res://ui/ButTagFilter.tscn")

onready var Popups = get_node("/root/Main/Popups")

onready var GridFilter = get_node("VBoxContainer/GridFilter")
onready var GridTop = get_node("VBoxContainer/GridTop")
onready var ButTagAdd = get_node("VBoxContainer/HBoxContainer/ButTagAdd")
onready var LineTag = get_node("VBoxContainer/HBoxContainer/LineTag")
onready var ButAccept = get_node("VBoxContainer/HBoxBut/ButAccept")
onready var ButCancel = get_node("VBoxContainer/HBoxBut/ButCancel")
onready var ViewListItem = get_node("../../HBoxContainer/Panel/LeftDisplay/ViewListItem")

var dic_top = {} #Holds the top 12 tags
var filtered_tags = []
var filtered_tags_prev = []

func _ready():
	ButTagAdd.connect("pressed",self,"_on_ButTagAdd_pressed")
	ButAccept.connect("pressed",self,"_on_ButAccept_pressed")
	ButCancel.connect("pressed",self,"_on_ButCancel_pressed")
	
func top_refresh():
	global.children_delete(GridTop)
	dic_top = {}
	#filtered_tags_prev = filtered_tags
	
	#Find top tags
	var keys = global.db_tags_count.keys()
	var values = global.db_tags_count.values()
	var size = global.db_tags_count.size()
	
	var cur = 0
	
	while cur < 12:
		var keys_index = keys[size-1-cur]
		var values_index = values[size-1-cur]
		
		dic_top[keys_index] = values_index#Rebuild a new dictionary
		cur += 1
	
	#Create buttons for top tags
	
	for i in dic_top:
		var temp = ButTagFilter.instance()
		GridTop.add_child(temp) #load button into the right container
		var node_path = NodePath(get_path_to(temp)) #locate the newly created button
		temp = get_node(node_path) #get button
		
		temp.stored_str = i #save identifier
		if !temp.is_connected("pressed", self, "_on_ButTopTag_pressed"):
			temp.connect("pressed", self, "_on_ButTopTag_pressed", [temp])
		temp.text = str(i + " - " + str(dic_top[i]))
	
	filter_refresh()
	
func filter_refresh(): #Separate refresh for filtered tags since it's called more often
	global.children_delete(GridFilter)
	
	if filtered_tags.size() > 0:
		for i in filtered_tags:
			var temp = ButTagFilter.instance()
			GridFilter.add_child(temp) #load button into the right container
			var node_path = NodePath(get_path_to(temp)) #locate the newly created button
			temp = get_node(node_path) #get button
			
			temp.stored_str = i #save identifier
			if !temp.is_connected("pressed", self, "_on_ButFilteredTag_pressed"):
				temp.connect("pressed", self, "_on_ButFilteredTag_pressed", [temp])
			temp.text = i
		
func _on_ButTagAdd_pressed():
	var tag = LineTag.text
	LineTag.text = ""
	
	if !filtered_tags.has(tag):
		filtered_tags.append(tag)
		
		var temp = ButTagFilter.instance()
		GridFilter.add_child(temp) #load button into the right container
		var node_path = NodePath(get_path_to(temp)) #locate the newly created button
		temp = get_node(node_path) #get button
		
		temp.stored_str = tag #save identifier
		if !temp.is_connected("pressed", self, "_on_ButFilteredTag_pressed"):
			temp.connect("pressed", self, "_on_ButFilteredTag_pressed", [temp])
		temp.text = tag

func _on_ButAccept_pressed():
	visible = 0
	Popups.visible = 0
	ViewListItem.directory_filter()
	
func _on_ButCancel_pressed():
	visible = 0
	Popups.visible = 0
	filtered_tags = filtered_tags_prev #Restore old filtered tags
	print(filtered_tags_prev)
	
func _on_ButFilteredTag_pressed(but): #Remove a tag from the filter
	if filtered_tags.has(but.stored_str):
		filtered_tags.erase(but.stored_str)
	
	but.queue_free()

func _on_ButTopTag_pressed(but):
	var tag = but.stored_str
	
	if !filtered_tags.has(tag):
		filtered_tags.append(tag)
		
		var temp = ButTagFilter.instance()
		GridFilter.add_child(temp) #load button into the right container
		var node_path = NodePath(get_path_to(temp)) #locate the newly created button
		temp = get_node(node_path) #get button
		
		temp.stored_str = tag #save identifier
		if !temp.is_connected("pressed", self, "_on_ButFilteredTag_pressed"):
			temp.connect("pressed", self, "_on_ButFilteredTag_pressed", [temp])
		temp.text = tag
		
	
