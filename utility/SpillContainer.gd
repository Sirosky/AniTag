extends Container
class_name SpillContainer

var children_index = []
var hbox_index = []
var cur_hbox = 0 #Which hbox our children are going into now
var vbox

func _notification(what):
	match what:
		NOTIFICATION_SORT_CHILDREN:
			
			children_index = []
			for n in self.get_children():
				children_index.append(n)
			
			#Create first HBox
			var hbox = HBoxContainer.new()
			vbox.add_child(hbox)
			hbox_index.append(hbox)
			cur_hbox = 0
			
			if children_index.size()>0:
				for i in children_index:
					
					self.remove_child(i)
					hbox_index[cur_hbox].add_child(i)
					i.set_owner(hbox_index[cur_hbox])
					fit_child_in_rect(i, Rect2( Vector2(), rect_size ) )
					
			
		
		NOTIFICATION_READY:# code put here executes at the same time as _ready()
			vbox = VBoxContainer.new()
			add_child(vbox)