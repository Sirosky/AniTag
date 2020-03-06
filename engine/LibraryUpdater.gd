extends Node
#Responsible for downloading/ reading XMLs from AniDB
"""
Order of calling
1) anidb_init
2) anidb_access_api
3) _on_HTTPRequest_request_completed
4) anidb_decompress
5) _process
6) anidb_xml_rename
7) anidb_pass_db
8) anidb_access_cover
9) anidb_refresh_cover

"""

var search
var lib_update_stage = 0
var lib_update_stage_max = 8
var ani_id_check = 0 #ID of the anime just extracted
var timer = 0
var forced_update = 0 #Force download update to show even if cache already exists

var bulk_updating = 0
var bulk_timer = 0
var bulk_timer_default = 180
var bulk_index: float = 0
var bulk_continue = 0
var t

onready var HTTPR = $HTTPRequest
onready var par = get_node("../")
onready var LibBuilder = get_node("../LibraryBuilder")
onready var LibLoader = get_node("/root/Main/Library/LibraryLoader")
onready var ItemDisplay = get_node("../../HBoxContainer/ItemDisplay")
onready var Cover = get_node("../../HBoxContainer/ItemDisplay/VBoxContainer/TopHBox/Cover")
onready var Popups = get_node("/root/Main/Popups") 
onready var LoadPanel = get_node("../../Popups/LoadPanel")
onready var LoadStatus = get_node("../../Popups/LoadPanel/LoadStatus")

func _ready():
	HTTPR.connect("request_completed",self,"_on_HTTPRequest_request_completed")
	#print(masterdb_get_id("Naruto"))
	"""
	
	var tar_show = masterdb_get_id("Naruto")
	
	if tar_show >= 0:
		global.anidb_search_id = tar_show
		anidb_access_api(global.anidb_search_id)
	"""
	
	#print(parse_db(14116, '(?<=<description>)(.*)(?=</description>)', 0))
	#print(parse_db(10716, '(?<=<description>)(.*)(?=</description>)', 0))
	#print(parse_db_advanced(14116, '<?xml', '<ratings>', '(?<=<descri)(.*)(?=cription>)', 0))
	#print(parse_db_dumb(14116, '<?xml', '<ratings>','<description>','</description>'))
	#parse_db(6675, '(?<=<name>)(.*)(?=</name>)', 0) #Find only first instance
	#parse_db(6675, '(?<=<name>)(.*)(?=</name>)', 1) #Find all available instances, used for getting tags
	#parse_db_advanced(6675, '<tags>', '</tags>', '(?<=<name>)(.*)(?=</name>)', 1)
	#anidb_access_image(2012, 237235)
func bulk_update():
	var db_size: int = int(global.db.size())
	print("db_size")
	print(db_size)
	if bulk_updating == 0: #Initiate generation
		bulk_updating = 1
		bulk_index = 0
		global.db_cur_key = global.db.keys()[bulk_index-1]
		if global.db_cur_key == "_Settings": #Skip Settings
			bulk_index += 1
			global.db_cur_key = global.db.keys()[bulk_index-1]
		anidb_init(global.db_cur_key)
		Popups.visible = 1
		LoadPanel.visible = 1
		LoadStatus.visible = 1
	else: #Continue generation
		if bulk_index<db_size:
			
			bulk_index += 1
			global.db_cur_key = global.db.keys()[bulk_index-1]
			if global.db_cur_key == "_Settings": #Skip Settings
				bulk_index += 1
				bulk_update()
				return
			anidb_init(global.db_cur_key)
			global.load_status = str(str(global.db[global.db_cur_key]["name"])+" ("+str(stepify((bulk_index/(db_size-1))*100, .1))+"%)")
			print(global.load_status)
		else:
			global.Mes.message_send("Bulk update complete.")
			print("Job complete.")
			LoadPanel.visible = 0
			LoadStatus.visible = 0
			Popups.visible = 0
			global.load_status_prepend = ""
			global.load_status = ""
			bulk_updating = 0
			bulk_continue = 0
			bulk_index = 0
			LibLoader.library_load() #Reload the file
	
	
func anidb_init(tar_show): #Use this method to start a new search
	#Update loading
	#tar_show = name of the show
	Popups.visible = 1
	LoadPanel.visible = 1
	LoadStatus.visible = 1
	global.load_status_prepend = ""
	global.load_status = ""
	
	print(global.db_cur_key)
	var ani_id = masterdb_get_id(str(global.db[global.db_cur_key]["anidb_name"]))
	global.load_status = str("Retrieving AniDB ID")
	
	if ani_id == null: #Didn't find show
		if bulk_updating == 1:
			bulk_continue = 1
			bulk_timer = bulk_timer_default/2
		else: #If just updating a single show, cancel the search
			LoadPanel.visible = 0
			LoadStatus.visible = 0
			Popups.visible = 0
			global.load_status_prepend = ""
			global.load_status = ""
			global.Mes.message_send("Title not found. Please input AniDB ID manually.")
		print("Null AniDB ID")
		return
	elif ani_id >= 0:
		global.anidb_search_id = ani_id
		anidb_access_api(global.anidb_search_id)
		
	

func anidb_access_api(ani_id):
	var file_temp = File.new() #Verify file rename succeeded
	lib_update_stage = 0
	
	if !file_temp.file_exists("user://db/anidb/"+str(ani_id)+"/"+str(ani_id)+".xml") or forced_update == 1:
	
		var download_link = global.anidb_api_url+str(ani_id)
		global.load_status = str("Updating metadata: " + str(ani_id))
		
		#$HTTPRequest.set_download_file(str(str(down_path+str(anidb_id)+".xml")))
		HTTPR.set_download_file("user://db/anidb/"+str(ani_id)+".tmp")
		HTTPR.request(download_link)
		print(HTTPR.get_body_size())
	else: #Show already exists in our DB
		global.load_status = str("Local DB located. Updating from local DB.")
		anidb_pass_db(ani_id, 1)
	
func anidb_decompress(ani_id): #Called only after anidb_access_api has downloaded the API
	var file_temp = File.new()
	var zip_path = ProjectSettings.globalize_path("res://dependencies/7za.exe")
	var out_path = ProjectSettings.globalize_path("user://db/anidb/")
	
	if file_temp.file_exists("user://db/anidb/"+str(ani_id)+".tmp"):
		lib_update_stage = 2
		OS.execute(zip_path, ["e", str(out_path)+str(ani_id)+".tmp", "-y", "-o"+str(out_path)], 0)
		global.load_status = str("Decompressing XML DB")
		ani_id_check = ani_id
		timer = 30
	else:
		#anidb_pass_db(ani_id, 1)
		global.load_status = str("File not found. Download likely failed :(")
	
	file_temp.close()



func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	
	print(result)
	print(response_code)
	print(headers)
	print(body)
	
	if lib_update_stage == 0: #Decompressing a .XML
		lib_update_stage = 1
		anidb_decompress(global.anidb_search_id)
		
	if lib_update_stage == 6: #Just downloaded a cover image
		global.load_status = str("Cover image updated")
		lib_update_stage = 7
		anidb_refresh_cover(global.anidb_search_id)



func _process(_delta):
	#Check if unzipped exists
	
	if lib_update_stage == 2 and timer == 0: #Time to check file
		var file_temp = File.new()
		
		if file_temp.file_exists("user://db/anidb/"+str(ani_id_check)): #Check if file has been extracted
			var parser = File.new()
			parser.open("user://db/anidb/"+str(ani_id_check),File.READ)
			var str_main = parser.get_as_text()
			var str_search = "" #String which will be used for the search
			parser.close()
			
			var str_pos = str_main.findn("<episodecount>")
			
			if str_pos == -1: #String does not exist
				print("Title string not found, potentially banned.")
				str_pos = str_main.findn("<Banned>")
				if str_pos > -1: #Check if we had been banned
					print("API ban")
					global.load_status = str("Potential API ban")
					pass
				else: #Haven't been banned, which means extraction is incomplete
					timer = 30 #Reset timer and try again
			else: #String does exist, extraction complete
				lib_update_stage = 3
				global.load_status = str("Yay! Extraction succeeded.")
				
				#Delete gzip
				var dir_temp = Directory.new()
				if dir_temp.file_exists("user://db/anidb/"+str(ani_id_check)+".tmp"):
					dir_temp.remove("user://db/anidb/"+str(ani_id_check)+".tmp")
					
				anidb_xml_rename(ani_id_check)
				
	if lib_update_stage > 0 and LoadPanel.visible:
		LoadStatus.text = str(str(global.load_status) + str(bulk_timer))
		
	if bulk_timer <= 0 and bulk_updating == 1 and bulk_continue == 1:
		bulk_continue = 0
		bulk_update()
		
	if timer > 0:
		timer -= 1
		
	if bulk_timer > 0:
		bulk_timer -= 1


func parse_db(ani_id, regex, return_all): #parse text
	#ani_id = id of the anime; regex = target string, eg '(?<=<startdate>)(.*)(?=</startdate>)'
	#return_all returns an array with all found hits [1/0]
	#print(db["Naruto"]["image"])
	
	var parse_tar = "user://db/anidb/"+str(ani_id)+"/"+str(ani_id)+".xml"
	var parser = File.new()
	if parser.file_exists(parse_tar):
		parser.open(parse_tar,File.READ)
	else:  #File doesn't exist
		print("XML DB not found")
		return null
	
	var text = parser.get_as_text()
	parser.close()
	var _regex = RegEx.new()
	#var regex_compiled = _regex.compile('/<startdate>(.*?)</startdate>/g')
	#var regex_compiled = _regex.compile('(?<=Naruto began)(.*)(?=in HD)') #this works
	var regex_compiled = _regex.compile(regex) #this works
	
	if regex_compiled  == 0:
		var result
		if return_all == 0:
			result = _regex.search(text)
		else:
			result = _regex.search_all(text)
		
		if result != null:
			if return_all == 0:
				return result.get_string()
			else: 
				var result_temp = result.duplicate(0) #We have to convert the RegExMatch array into a normal array
				
				for i in range(0, result_temp.size()):
					result[i] = result_temp[i].get_string()
				return result
		else:
			print("parse_db couldn't find target")
	else:
		print("Regex compile failed")
		global.Mes.send_message("Regex compile failed")

func parse_db_advanced(ani_id, delim_1, delim_2, regex, return_all): #parse text
	#Used to conduct a 2 tier search to narrow down returned strings
	#delim_1/2 set the delimitations of where to search
	#ani_id = id of the anime; regex = target string, eg '(?<=<startdate>)(.*)(?=</startdate>)'
	#return_all returns an array with all found hits [1/0]
	#print(db["Naruto"]["image"])
	
	var parse_tar = "user://db/anidb/"+str(ani_id)+"/"+str(ani_id)+".xml"
	var parser = File.new()
	if parser.file_exists(parse_tar):
		parser.open(parse_tar,File.READ)
	else:  #File doesn't exist
		print("XML DB not found")
		return null
	
	var text = parser.get_as_text()
	parser.close()
	var _regex = RegEx.new()
	var regex_compiled = _regex.compile(regex)
	var search_str = "" #String to be used in second search
	
	#Crop the string	
	var pos = text.findn(delim_1) #Find position of first string
	if pos!= -1:
		var str_1 = text.right(pos+delim_1.length()) #Get everything to the right of first string
		pos = str_1.findn(delim_2) #Find second string
		if pos!= -1:
			search_str = str_1.left(pos) #Get everything to the left of the second string
	
	if pos == -1:
		print("One or more delimiters not found")
		return null
	
	if regex_compiled  == 0:
		var result
		if return_all == 0:
			result = _regex.search(search_str)
		else:
			result = _regex.search_all(search_str)
		
		if result!=null:
			if return_all == 0:
				print(result.get_string())
				return result.get_string()
			else: 
				var result_temp = result.duplicate(0) #We have to convert the RegExMatch array into a normal array
				
				for i in range(0, result_temp.size()):
					result[i] = result_temp[i].get_string()
				
				#print(result)
				return result		
	else:
		print("Regex compile failed")
		return null
		
func parse_db_dumb(ani_id, delim_1, delim_2, delim_3, delim_4): #parse text
	#Alternative to parse_db_advanced. Use when parse_db_advanced doesn't work for some reason.
	#No Regex used here.
	#Used to conduct a 2 tier search to narrow down returned strings
	#delim_1/2 set the delimitations of where to search
	#ani_id = id of the anime;
	#returns text between delims 3/4
	
	var parse_tar = "user://db/anidb/"+str(ani_id)+"/"+str(ani_id)+".xml"
	var parser = File.new()
	if parser.file_exists(parse_tar):
		parser.open(parse_tar,File.READ)
	else:  #File doesn't exist
		print("XML DB not found")
		return null
	
	var text = parser.get_as_text()
	parser.close()
	
	var search_str = "" #String to be used in second search
	
	#Crop the string	
	var pos = text.findn(delim_1) #Find position of first string
	if pos!= -1:
		var str_1 = text.right(pos+delim_1.length()) #Get everything to the right of first string
		pos = str_1.findn(delim_2) #Find second string
		if pos!= -1:
			search_str = str_1.left(pos) #Get everything to the left of the second string
	
	if pos == -1:
		print("One or more delimiters not found")
		return null
	
	#Crop string again
	
	pos = search_str.findn(delim_3) #Find position of first string
	if pos!= -1:
		var str_1 = search_str.right(pos+delim_3.length()) #Get everything to the right of first string
		pos = str_1.findn(delim_4) #Find second string
		if pos!= -1:
			search_str = str_1.left(pos) #Get everything to the left of the second string
	
	if pos == -1:
		print("One or more delimiters 3/4 not found")
		return ""
	else:
		return search_str
	

func masterdb_get_id(title: String): 
	#Parses anidb master XML list using title to find anidb id
	
	var parser = File.new()
	
	parser.open("res://settings/anime-list-master.xml",File.READ)
	
	print(title)
	
	var str_main = parser.get_as_text()
	var str_search = "" #String which will be used for the anidbid= search
	var str_search_regex = "" #Final string
	parser.close()
	
	#Find title, and carve out string for regex search
	
	var str_pos = str_main.findn(title)
	
	if str_pos == -1:
		var p = str("Title string not found on AniDB") #Not found in masterlist
		global.load_status = p
		print(p)
		
		if bulk_updating != 1:
			Popups.visible = 0
			LoadPanel.visible = 0
		
		if int(global.db[global.db_cur_key]["id"]) > -1: #ID might be manually filled out
			return int(global.db[global.db_cur_key]["id"])
		else:
			return null
	else:
		#Got the position of the title, offset a bit
		var str_pos_offset = str_pos-150
		#print(str_pos)
		#print(str_pos_offset)
		str_search = str_main.substr(str_pos_offset, 150)
	
	#print(str_search)
	#Narrowed down string, now search for anidbid="
	
	str_pos = str_search.findn('anidbid="')
	var str_length = 9 #Length of anidbid="
	
	if str_pos == -1: #anidbid string not found, possible issue with master xml list
		print("anidbid string not found")
		return null
	else:
		str_search = str_search.substr(str_pos+str_length,5)
		#print(str_search)
	
	#Found position of ID, now extract ID number
	
	var _regex = RegEx.new()
	
	#var regex_compiled = _regex.compile('(?s)<anime .*?<name>Gibiate')
	#var regex_compiled = _regex.compile('<anime.*?anidbid="(?<anidbid>\\d+)"') #this works
	var regex_compiled = _regex.compile('\\d+') #only take digits
	
	if regex_compiled  == 0:
		var result = _regex.search(str_search)
		#print(result)
		if result!=null:
			#print(result.get_string())
			return int(result.get_string())
		else: #Show not found
			print("Show not found")
			return null
	else:
		print("Regex compile failed")
		return null
		
func masterdb_get_name(anidb_id): 
	#Parses anidb master XML list using anidb id to get title
	
	var parser = File.new()
	
	parser.open("res://settings/anime-list-master.xml",File.READ)
	
	var str_main = parser.get_as_text()
	var str_search = "" #String which will be used for the anidbid= search
	var str_search_regex = "" #Final string
	parser.close()
	
	var str_pos = str_main.findn(str('anidbid="'+str(anidb_id)+'"'))
	var str_length = str('anidbid="'+str(anidb_id)+'"').length()
	
	if str_pos == -1:
		var p = str("AniDB ID not found.")
		global.load_status = p
		print(p)
		return null
	else:
		#Got the position of the title, offset a bit
		var str_pos_offset = str_pos+str_length
		str_search = str_main.substr(str_pos_offset, 180)
		return parse_string(str(str_search),"","",'<name>','</name>')
		

func anidb_xml_rename(ani_id):
	#Rename extracted file, change ext to XML
	var dirtemp= Directory.new()	
	var file_temp = File.new() #Verify file rename succeeded
	
	if file_temp.file_exists("user://db/anidb/"+str(ani_id)):
		
		#Give it a .xml extension, make directory, then move it into new directory
		
		print(dirtemp.rename("user://db/anidb/"+str(ani_id),"user://db/anidb/"+str(ani_id)+".xml"))
		print(dirtemp.make_dir("user://db/anidb/"+str(ani_id)))
		print(dirtemp.rename("user://db/anidb/"+str(ani_id)+".xml","user://db/anidb/"+str(ani_id)+"/"+str(ani_id)+".xml"))
	
	if file_temp.file_exists("user://db/anidb/"+str(ani_id)+"/"+str(ani_id)+".xml"):
		global.load_status = str("Configuring DB")
		print("Rename suceeded")
		lib_update_stage = 4
		anidb_pass_db(ani_id, 1)
	else:
		print("Rename failed")
		
func anidb_pass_db(ani_id, update_images):
	#Passes info from XML to currently loaded DB
	#update_images = 1 means download new cover image
	lib_update_stage = 5
	
	if global.db.size() > 0:
		global.load_status = str("Updating library entry")
		
		global.db[global.db_cur_key]["id"] = parse_db(ani_id, '(?<=<anime id=")(.*)(?=" restricted)', 0)
		global.db[global.db_cur_key]["anidb_name"] = parse_db(ani_id, '(?<=<title xml:lang="x-jat" type="main">)(.*)(?=</title>)', 0)
		global.db[global.db_cur_key]["name_eng"] = parse_db(ani_id, '(?<=<title xml:lang="en" type="official">)(.*)(?=</title>)', 0)
		if global.db[global.db_cur_key]["name_eng"] == null: #We didn't find anything, try an alternative
			global.db[global.db_cur_key]["name_eng"] = parse_db(ani_id, '(?<=<title xml:lang="en" type="synonym">)(.*)(?=</title>)', 0)
		if global.db[global.db_cur_key]["name_eng"] == null: #Really didn't find anything
			global.db[global.db_cur_key]["name_eng"] = ""
		global.db[global.db_cur_key]["date"] = parse_db(ani_id, '(?<=<startdate>)(.*)(?=</startdate>)', 0)
		global.db[global.db_cur_key]["anidb_description"] = parse_db_dumb(ani_id, '<?xml', '<ratings>','<description>','</description>') #For some dumb reason, regex doesn't find correct desc sometimes
		global.db[global.db_cur_key]["episodes"] = parse_db(ani_id, '(?<=<episodecount>)(.*)(?=</episodecount>)', 0)
		global.db[global.db_cur_key]["image"] = parse_db_dumb(ani_id, '</ratings>', '<resources>','<picture>','</picture>')
		global.db[global.db_cur_key]["anidb_tags"] = parse_db_advanced(ani_id, '<tags>', '</tags>', '(?<=<name>)(.*)(?=</name>)', 1)
		global.db[global.db_cur_key]["anidb_score"] = parse_db_advanced(ani_id, '<ratings>', '</ratings>', '(?<=">)(.*)(?=</permanent>)', 0)
		#Failsafe when tags are null. Happens when AniDB has no tags for the show
		if global.db[global.db_cur_key]["anidb_tags"] == null:
			global.db[global.db_cur_key]["anidb_tags"] = []
		
		#Return array with everything from the staff
		var staff = parse_db_advanced(ani_id, '<creators>', '</creators>','(?<=<name id)(.*)(?=name>)', 1)
		
		if staff!=null:
			global.db[global.db_cur_key]["staff"].clear()
			
			for i in range(staff.size()):
				var key = parse_string(str(staff[i]),"","",'type="','">')
				var value = parse_string(str(staff[i]),"","",'">','</')
				global.db[global.db_cur_key]["staff"][key] = value
				
		#Beautify description
		
		var comp = 0
		var st = global.db[global.db_cur_key]["anidb_description"]
		
		while comp == 0: #First search
			var tar = st.findn("]")
			#print(str("tar str location " + str(tar)))
			
			if tar > -1: #Found
				st.erase(tar, 1)
				#print("Deleted ]")
			else: #Nothing found, end search
				comp = 1
				
		comp = 0
				
		while comp == 0: #Second search
			var tar = st.findn("http")
			var tar2 = st.findn("[", tar)
			var l = tar2 - tar
			#print(tar)
			#print(tar2)
			#print(l)
			
			if tar > -1: #Found
				st.erase(tar, l+1)
				#print("Deleted http")
			else: #Nothing found, end search
				comp = 1
		
		global.db[global.db_cur_key]["anidb_description"] = st
		
		#Now parse related anime	
		var related = parse_db_advanced(ani_id, '<relatedanime>', '</relatedanime>','(?<=<anime i)(.*)(?=nime>)', 1)
		
		if related!=null:
			global.db[global.db_cur_key]["related"].clear()
			
			for i in range(related.size()):
				#Key is anidb id, value is the type of related anime-- if any.
				var key = parse_string(str(related[i]),"","",'d="','" ')
				var value = parse_string(str(related[i]),"","",' type="','">')
				
				if value == null:
					value = ""
				
				global.db[global.db_cur_key]["related"][key] = value
		
		global.Mes.message_send("Database update complete.")
		global.json_write("user://db/"+global.db_name,global.db)
		
		if bulk_updating == 0: #Don't refresh if doing a bulk update
			ItemDisplay.display_refresh()
		else:
			anidb_refresh_cover(ani_id)
		
		if update_images==1:
			anidb_access_cover(ani_id)
		
	else:
		print("No library loaded")
		lib_update_stage = 0
		

func anidb_access_cover(ani_id):
	#Download cover image
	lib_update_stage = 6
	var file_temp = File.new() #Verify file rename succeeded
	
	
	
	if global.db.size() > 0:
		if !file_temp.file_exists("user://db/anidb/"+str(ani_id)+"/cover.jpg") or forced_update == 1:
			global.load_status = str("Downloading cover image")
			var download_link = global.anidb_cdn_url+str(global.db[global.db_cur_key]["image"])
			
			#$HTTPRequest.set_download_file(str(str(down_path+str(anidb_id)+".xml")))
			HTTPR.set_download_file("user://db/anidb/"+str(ani_id)+"/cover.jpg")
			HTTPR.request(download_link)
		elif global.db_key_v == global.db_cur_key:
			global.load_status = str("Cover image already exists. Refreshing.")
			print("Local cover image exists")
			anidb_refresh_cover(ani_id)
			


func anidb_refresh_cover(ani_id):
	#Refreshes current selected anime's cover image displayed based on local files
	lib_update_stage = 8 #This is the last step
	var file_temp = File.new() #Verify file rename succeeded
	var image_path = "user://db/anidb/"+str(ani_id)+"/cover.jpg"
	var import_path = "user://db/anidb/"+str(ani_id)+"/cover.jpg.import"
	Cover.texture = load("res://ui/themes/default/cover.png")
	
	
	if global.db.size() > 0:
		if file_temp.file_exists(image_path) and bulk_updating == 0:
			global.load_status = str("Refreshing cover image")
			
			#if file_temp.file_exists(import_path):
			#	Cover.texture = load(image_path)
			#else:
				
				#print("Image not imported, load manually")
			
			#Load images manually, since it's an external image
			var image = Image.new()
			var err = image.load(image_path)
			
			if err != OK:
				print("Error loading cover")
				global.load_status = str("Cover image couldn't be loaded :(")
				return
			else:
				var texture = ImageTexture.new()
				texture.create_from_image(image,7)
				Cover.texture = texture
				
	if lib_update_stage > 0: #We are in the middle of updating
		lib_update_stage = 0 #Last stop, end the update
		
		if bulk_updating == 0:
			LoadPanel.visible = 0
			LoadStatus.visible = 0
			Popups.visible = 0
			global.load_status_prepend = ""
			global.load_status = ""
		else:
			bulk_continue = 1
			bulk_timer = bulk_timer_default


func anidb_access_image(ani_id, image_id):
	var file_temp = File.new() #Verify file rename succeeded
	var dir_temp = Directory.new()
	lib_update_stage = -1
	
	if !file_temp.file_exists("user://db/anidb/"+str(ani_id)+"/"+str(ani_id)):
		dir_temp.make_dir("user://db/anidb/"+str(ani_id)) #make new directory if current one doesn't exist for ani_id
	
	var download_link = "http://cdn-us.anidb.net/images/main/"+str(image_id)+".jpg"
	
	#$HTTPRequest.set_download_file(str(str(down_path+str(anidb_id)+".xml")))
	HTTPR.set_download_file("user://db/anidb/"+str(ani_id)+"/"+str(image_id)+".jpg")
	HTTPR.request(download_link)
	
func parse_string(text, delim_1, delim_2, delim_3, delim_4): #parse text
	#No Regex used here.
	#Used to conduct a 2 tier search to narrow down returned strings
	#delim_1/2 set the delimitations of where to search
	#ani_id = id of the anime;
	#returns text between delims 3/4
	
	var search_str = "" #String to be used in second search
	
	#Crop the string
	if delim_1!="" and delim_2!="": #If both arguments are "" we can skip this step
		var pos = text.findn(delim_1) #Find position of first string
		if pos!= -1:
			var str_1 = text.right(pos+delim_1.length()) #Get everything to the right of first string
			pos = str_1.findn(delim_2) #Find second string
			if pos!= -1:
				search_str = str_1.left(pos) #Get everything to the left of the second string
		
		if pos == -1:
			print("One or more delimiters not found")
			return
	else:
		search_str = text
	
	#Crop string again
	
	var pos = search_str.findn(delim_3) #Find position of first string
	if pos!= -1:
		var str_1 = search_str.right(pos+delim_3.length()) #Get everything to the right of first string
		pos = str_1.findn(delim_4) #Find second string
		if pos!= -1:
			search_str = str_1.left(pos) #Get everything to the left of the second string
	
	if pos == -1:
		print("One or more delimiters 3/4 not found")
		return ""
	else:
		return search_str
		
