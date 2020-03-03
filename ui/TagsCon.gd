extends VBoxContainer
#Spill container

var hbox_index = [] #Array of all the HBox children
var cur_hbox #The hbox we're currently sending children into
var x_size = rect_size.x #Max width the buttons can extend to

func _ready():
	pass
	#create_hbox()

func create_hbox():
	var hbox = HBoxContainer.new()
	add_child(hbox)
	hbox_index.append(hbox) #Add it to our array
	hbox.rect_size.x = x_size
	cur_hbox = hbox_index.size()-1

func sort_children(class_n , width, separation):
	var but_size = {} #Dictionary holding button as key, and its with as value
	var cum_size = 0 #Cumulative size of all the buttons
	var but_sep = separation #By default hbox uses a separation of 3?
	var win_size = OS.get_window_size()
	#x_size = win_size.x-rect_position.x #Max width the buttons can extend to
	x_size = width
	#print("x_size-"+str(x_size))
	create_hbox() #Create the initial hbox
	
	for i in get_children():
		if i.get_class() == class_n: #Make sure we're only selecting buttons
			remove_child(i)
			hbox_index[cur_hbox].add_child(i) #Reparent to initial hbox
	
	yield(get_tree(), "idle_frame") #Allow buttons to resize properly
	
	for i in hbox_index[cur_hbox].get_children():
		but_size[i] = i.rect_size.x #Get button size
	
	for i in hbox_index[cur_hbox].get_children(): #Reparent buttons back to us
		hbox_index[cur_hbox].remove_child(i)
		add_child(i)
	
	for i in but_size.keys(): #Using the dictionary of buttons, parent buttons to appropriate hbox
		if (cum_size + but_size[i] + but_sep) <= x_size: #Check if next button exceeds max width
			remove_child(i)
			hbox_index[cur_hbox].add_child(i)
			cum_size += but_size[i] + but_sep
			#print(str(cum_size)+" "+str(cur_hbox)+" "+ str(i.text))
			
			#Failsafe- sometimes the calculation for sizes aren't accurate.
			hbox_index[cur_hbox].rect_size.x = x_size
			if hbox_index[cur_hbox].rect_size.x > x_size: #Still too big
				#print("reparenting oversized-"+str(hbox_index[cur_hbox].rect_size.x))
				hbox_index[cur_hbox].rect_size.x = x_size
				cum_size = but_size[i] + but_sep
				hbox_index[cur_hbox].remove_child(i)
				create_hbox() #Create new hbox
				hbox_index[cur_hbox].add_child(i) #Reparent button to new hbox
			
		else: #Next button does exceed max width, move it to a new row
			#print("reparenting-"+str(cum_size+but_size[i] + but_sep))
			#print("previous hbox-"+str(hbox_index[cur_hbox].rect_size.x))
			cum_size = but_size[i] + but_sep
			remove_child(i)
			create_hbox() #Create new hbox
			hbox_index[cur_hbox].add_child(i) #Reparent button to new hbox
			#print(str(cum_size)+" "+str(cur_hbox)+" "+ str(i.text))
			
	
	#print("x_size-"+str(x_size))
	rect_size.x = x_size
	#print("rect_size.x-"+str(rect_size.x))
	hbox_index = [] #Reset for use next time
