extends Node
# Handles thumbnails
var file_search = FileSearch.new() #Launch file search class
var thumbs_index = []
var thumbs_generating = 0 #0- inactive; 1- active
var thumbs_generating_bulk = 0 #0- inactive; 1- active
var ffmepg_path = ProjectSettings.globalize_path("res://dependencies/ffmpeg.exe")
var output_path = ProjectSettings.globalize_path("user://db/anidb/")
var thumbs_timer = 0 #Timer which figures out how long it takes to generate a thumb
var thumbs_count = 0 #Number of thumbs generated so far
var thumbs_delay = 0
var thumbs_delay_default = 15
var thumbs_first_generated = 0 #Whether first thumbnail has been generated
var thumbs_check = 0 #Whether we have checked for previously created thumbnails
var checks_made = 0

var bulk_index = 0 #Currently processing this entry
var bulk_timer = 0
var bulk_timer_delay = 30
var bulk_continue = 0 #When it's 1, move on to the next entry

#For displaying generated thumbnails
var job_index = 0 #Currently processing this entry
var job_timer = 0
var job_timer_delay = 5
var job_continue = 0 #When it's 1, move on to the next entry
var thumbs_sorted = []
var thumbs_total_width

onready var ThumbsCon = get_node("/root/Main/HBoxContainer/ItemDisplay/VBoxContainer/ThumbsCon")
onready var Thumb = preload("res://ui/Thumb.tscn")
onready var ItemDisplay = get_node("/root/Main/HBoxContainer/ItemDisplay")
onready var Tween = get_node("/root/Main/Tween")

onready var Popups = get_node("/root/Main/Popups") 
onready var LoadPanel = get_node("/root/Main/Popups/LoadPanel")
onready var LoadStatus = get_node("/root/Main/Popups/LoadPanel/LoadStatus")


# Called when the node enters the scene tree for the first time.
func _ready():
	thumbs_total_width = ThumbsCon.rect_size.x - (ThumbsCon.columns*16)

func thumbs_generate_bulk():
	#print(thumbs_generating_bulk)
	
	if thumbs_generating_bulk == 0: #Initiate generation
		thumbs_generating_bulk = 1
		bulk_index = 0
		global.db_cur_key = global.db.keys()[bulk_index-1]
		
		if global.db_cur_key == "_Settings":
			bulk_index += 1
			global.db_cur_key = global.db.keys()[bulk_index-1]
			print(global.db_cur_key)
			print(bulk_index)
		
		global.load_status = str("Now processing: "+str(global.db[global.db_cur_key]["name"]))
		thumbs_generate()
		LoadPanel.visible = 1
		LoadStatus.visible = 1
		Popups.visible = 1
	else: #Continue generation
		
		if bulk_index<global.db.size() - 1:
			bulk_index += 1
			global.db_cur_key = global.db.keys()[bulk_index-1]
			print(global.db_cur_key)
			global.load_status = str("Now processing: "+str(global.db[global.db_cur_key]["name"]))
			thumbs_generate()
		else:
			print("Job complete.")
			global.Mes.message_send("Bulk thumbnail generation complete.")
			thumbs_refresh()
			LoadPanel.visible = 0
			LoadStatus.visible = 0
			Popups.visible = 0
			thumbs_generating_bulk = 0


func thumbs_generate():
	var ani_id = int(global.db[global.db_cur_key]["id"])
	output_path = ProjectSettings.globalize_path("user://db/anidb/"+str(ani_id)+"/")
	
	var search = file_search.search_regex(global.filter_vid_regex, global.db[global.db_cur_key]["path"], 0)
	
	if search.size()<1:
		print("Video files missing.")
		return
	
	var tar_path = search.keys()[0] #Get first path
	thumbs_count = 0
	
	if ani_id > 0:
		OS.execute(ffmepg_path, ["-i",tar_path,"-vf","fps=1/150",str(output_path+"thumb%d.jpg"),"-hide_banner"], 0)
		thumbs_generating = 1
		thumbs_timer = thumbs_delay_default
		thumbs_check = 1
		LoadPanel.visible = 1
		LoadStatus.visible = 1
		Popups.visible = 1
		global.load_status = "Loading"
	elif thumbs_generating_bulk == 1: #Skip anime we don't have anidb IDs for
		thumbs_generating = 0
		bulk_timer = bulk_timer_delay
		bulk_continue = 1
		print("ID not found, skipping")
		
func _process(delta):
	if thumbs_generating == 1 and thumbs_timer == 0: #If FFMPEG is generating thumbnails
		
		var search = file_search.search_string("thumb", output_path, 0) #Search for generated thumbnails
		var search_size = 0
		var dir = Directory.new()
		
		for i in search.keys(): #Make sure we have the right file. Dont count .imports
			if i.get_extension() == "jpg": 
				search_size+=1
		
		if thumbs_check == 1:
			if search_size>0: #There are pre-existing thumbnails. Delete them all!
				for i in search.keys():
					#print(i)
					dir.remove(str(i))
				search_size = 0
			thumbs_check = 0
		
		#global.load_status = "Generating thumbnail " + str(max(search_size, 1)) +"-" + str(thumbs_count)
		global.load_status = "Generating thumbnail " + str(max(search_size, 1))
		
		if search_size>0: #Images were generated
			if search_size == 1 and thumbs_first_generated == 0: #Calculte how often we should check 
				thumbs_delay = thumbs_delay_default*(checks_made+1)
				thumbs_first_generated = 1
				checks_made = 0	
			if search_size == thumbs_count: 
				#print("search_size == thumbs_count")
				if checks_made >= 2: #We're done! Reset everything
					thumbs_generating = 0
					thumbs_delay = thumbs_delay_default
					thumbs_first_generated = 0
					checks_made = 0
					thumbs_count = 0
					global.Mes.message_send("Thumbnails generated.")
					#print("checks_made >= 2")
					if thumbs_generating_bulk == 0: #If we're not doing a bulk job, can reset these
						thumbs_refresh()
						LoadPanel.visible = 0
						LoadStatus.visible = 0
						Popups.visible = 0
					else: #If we are in the middle of a bulk job, pause briefly then resume
						bulk_timer = bulk_timer_delay
						bulk_continue = 1
				else:
					checks_made += 1 #Check again-- might be done
			if search_size > thumbs_count:
				thumbs_count = search_size
				checks_made = 0	
		else: #Nothing generated yet
			checks_made += 1 #Slow down checks
			thumbs_delay = thumbs_delay_default
				
		thumbs_timer = thumbs_delay
		
		if LoadStatus.visible:
			LoadStatus.text = str(global.load_status)
			
	if bulk_timer == 0 and thumbs_generating_bulk == 1 and bulk_continue == 1: #Middle of a bulk job and timer met, start again
		thumbs_generating_bulk = 1
		#print("Preparing next title.")
		global.load_status = "Preparing next title."
		bulk_continue = 0
		thumbs_generate_bulk()
	
	if LoadStatus.visible:
		LoadStatus.text = str(global.load_status)
	
	if bulk_timer >- 1:
		bulk_timer-=1
		
	if job_timer >- 1:
		job_timer-=1

	thumbs_timer-=1
	
	if job_continue == 1 and job_timer == 0:
		#If job is finished, end everything
		thumbs_create(thumbs_sorted[job_index])
		job_index += 1
		job_timer = job_timer_delay
		
		if job_index > thumbs_sorted.size()-1:
			job_continue = 0
			job_index = 0
			job_timer = 0
			ThumbsCon.visible = 1
			#ThumbsCon.sort_children("TextureRect", ItemDisplay.rect_size.x,3)
		
		

func thumbs_refresh(): #Begins the refreshing job
	var ani_id = str(global.db[global.db_key_v]["id"])
	var search = file_search.search_regex_full_path("thumb", str("user://db/anidb/"+ani_id), 0)
	var import_array = [] #Array of .import files to be removed
	var image_num = 0
	if search.size()>0:
		global.children_delete(ThumbsCon)
		
		for i in search.keys(): #Make sure we have the right file. Dont count .imports
			if i.get_extension() == "import": 
				import_array.append(i)
		
		for i in import_array:
			search.erase(i)
		
		if !ThumbsCon.visible:
				ThumbsCon.visible = 1
		
		var keys = search.keys()
		thumbs_sorted = [] #Sorted in order
		keys.sort()
		var c = 1
		while c < (keys.size()+1): #Using a while loop to sort images in order
			var entry = str("user://db/anidb/"+ani_id+"/"+"thumb"+str(c)+".jpg")
			#print(entry)
			if keys.has(entry):
				thumbs_sorted.append(entry)
			else:
				print("E: Image " + str(entry) + " not found")
				return
			c+=1
		job_continue = 1 #Initiate the job
		job_index = 0
		job_timer = 1
		
	else:
		ThumbsCon.visible = 0

func thumbs_create(entry): #Create each individual thumbnail. Only called during refreshing job.
	if entry.get_extension() == "jpg": #Make sure we have the right file
		var temp=Thumb.instance()
		ThumbsCon.add_child(temp) #load button into the right container
		var node_path = NodePath(get_path_to(temp)) #locate the newly created button
		temp = get_node(node_path) #get button
		
		var image = Image.new()
		var err = image.load(entry)
		
		if err != OK:
			print("Error loading thumb- "+ str(err))
			global.load_status = str("Thumb couldn't be loaded :(")
			return
		
		var image_w = image.get_width()
		var image_h = image.get_height()
		var texture = ImageTexture.new()
		
		texture.create_from_image(image,7)
		temp.stored_str.append(entry)
		temp.texture = texture
		var size_mult = float(image_w)/float(image_h) #Resize image while keeping aspect ratio
		temp.rect_min_size.x = (thumbs_total_width/ThumbsCon.columns)
		temp.rect_min_size.y = temp.rect_min_size.x/size_mult
		temp.modulate = Color(1, 1, 1, 0)
		
		Tween.interpolate_property(temp, "modulate",Color(1, 1, 1, 0), Color(1, 1, 1, 1), .5, Tween.TRANS_SINE, Tween.EASE_OUT)
		Tween.start()

func _on_Thumb_pressed(thumb):
	print(thumb)
	pass
	
