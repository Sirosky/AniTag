extends Node

var anitag_version: String = "1.1.1"
var dir_path = ""
var window_width: int = ProjectSettings.get("display/window/size/width")
var window_height: int = ProjectSettings.get("display/window/size/height")
var screen_size = OS.get_screen_size()

var ani_selected #String of show selected

var db_path = "" #Holds path of the db
var db = {} #Holds actual DB dictionary be loaded from JSON; key = name
var db_name = "temp.json" #Name of the DB,  used when creating, loading, and updating DBs
var db_cur_key = "" #Current key in the DB that is being processed
var db_key_v #Current key that is being viewed. Only changed when new show is selected.
var db_tags_count = {} #Key = tag, value = number of times it shows up
var db_missing_id = [] #Array of entries missing IDs
var db_missing_thumb = [] #Array of entries missing thumbnails

#Used for sorting
var db_arr = [] #Holds an array of NAMES in alphabetical order
var db_arr_id = {} #Keys = names, values = the ID of the show used in db dic

var anidb_search_id = 0
var anidb_api_url = "http://api.anidb.net:9001/httpapi?request=anime&client=xbmcscrap&clientver=1&protover=1&aid="
var anidb_cdn_url = "http://cdn-us.anidb.net/images/main/"
var anidb_list_url = "https://raw.githubusercontent.com/Anime-Lists/anime-lists/master/anime-list-master.xml"
var down_path = "user://db/"

var filter_vid_regex = "(.mkv|.ogv|.mp4|.ogm|.avi|.mov|.flv|.wmv|.m4v|.mpg|.mpeg|.mpe)"

var load_status = "" #Status message to display while loading
var load_status_prepend = "" #Display in front of status message

var settings #Dictionary which holds settings
var settings_path = "res://settings/settings.json"

onready var Mes = get_node("/root/Main/Messenger")


# Called when the node enters the scene tree for the first time.
func _ready():
	
	window_width = OS.get_window_size().x
	window_height = OS.get_window_size().y
	
	

func json_read(json_path):
	#Open, read, and load JSON
	#PathJSON e.g. "res://data/test.json"
	var data_file = File.new()
	if data_file.open(json_path, File.READ) != OK:
		print("read error: " + str(json_path))
		return
	var data_text = data_file.get_as_text()
	data_file.close()
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		print("parse error: " + str(json_path))
		return
	print("parse successful: " + str(json_path))
	#print(data_parse.result)
	
	return data_parse.result

func json_write(json_path, dic):
	#Open, read, and load JSON
	#dic- dictionary to be stored in json
	#PathJSON e.g. "res://data/test.json"
	var data_file = File.new()
	if data_file.open(json_path, File.WRITE) != OK:
		print("read error: " + str(json_path))
		return
	
	data_file.store_line(to_json(dic))
	data_file.close()
	print("write success: " + str(json_path))
	
static func children_delete(node):
#Deletes all child nodes
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

#Sorting dictionaries

func dic_find_keys(dic, value):
	var arr = []
	
	for i in dic:
		if dic[i] == value:
			arr.append(i)
			
	return arr

func sort_dic_value(dic): #Sorts dictionary by value
	var _arr_keys = dic.keys()
	var arr_values = dic.values()
	var dic_sorted = {}
	
	arr_values.sort()
	
	#Delete duplicate values
	
	for i in arr_values:
		var dupes = arr_values.count(i)
		
		while dupes > 1:
			arr_values.erase(i)
			dupes-=1
	
	#print(arr_values)
	
	for i in arr_values:
		var keys = dic_find_keys(dic, i) #Returns an array of keys that had the value
		
		for ii in keys:
			dic_sorted[ii] = i #Add key-value pair to create sorted dictionary
	
	return dic_sorted
	
func window_manage():
	if global.settings["General"]["fullscreen"] == true:
		resolution_manager.set_fullscreen()
	else:
		resolution_manager.set_windowed()
