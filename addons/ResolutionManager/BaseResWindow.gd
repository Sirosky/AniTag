tool
extends WindowDialog

onready var width_node: LineEdit = find_node("Width");
onready var height_node: LineEdit = find_node("Height");
onready var option_node: OptionButton = find_node("OptionButton");
onready var option_popup: PopupMenu = option_node.get_popup();
onready var current_node: Label = find_node("CurrentRes");

func _ready():
	option_popup.connect("index_pressed", self, "_on_OptionButton_item_selected");


# Display current resolution:
func _on_BaseResWindow_about_to_show()-> void:
	option_node.text = "Choose pre-defined resolution";
	_clear_line_edit_texts()
	
	var current_size: Vector2 = Vector2();
	var x = ProjectSettings.get_setting("display/window/size/width");
	var y = ProjectSettings.get_setting("display/window/size/height");
	current_node.text = "Current resolution: ";
	current_node.text += String(x) + " x " + String(y);


# Extract size from option button text:
func _on_OptionButton_item_selected(id: int)-> void:
	var key = option_node.get_item_text(id);
	option_node.text = key;
	
	var size: Vector2 = Vector2();
	
	var array: PoolStringArray = key.split("x", false, 1);
	size.y = array[1].to_float();
	
	array = array[0].split("(", false, 1);
	size.x = array[1].to_float();
	
	width_node.text = String(size.x);
	height_node.text = String(size.y);


# Set base size:
func _on_Ok_pressed()-> void:
	var width: int = int(width_node.text);
	var height: int = int(height_node.text);

	if height == 0 or width == 0:
		var error_dialog = AcceptDialog.new();
		add_child(error_dialog);
		error_dialog.window_title = "Error";
		error_dialog.dialog_text = "Resolution not added because of incomplete\ndetails";
		error_dialog.popup_exclusive = true;
		error_dialog.popup_centered();
		error_dialog.show();
	else:
		ProjectSettings.set_setting("display/window/size/width", width);
		ProjectSettings.set_setting("display/window/size/height", height);
		ProjectSettings.save();
	
	hide();
	_clear_line_edit_texts();


func _on_Cancel_pressed()-> void:
	hide();
	_clear_line_edit_texts();


func _clear_line_edit_texts()-> void:
	width_node.clear();
	height_node.clear();
	width_node.placeholder_text = "Enter Width";
	height_node.placeholder_text = "Enter Height";



