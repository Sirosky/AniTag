tool
extends WindowDialog

signal reload;

onready var config_file: ConfigFile = ConfigFile.new();
onready var width_node: LineEdit = find_node("Width");
onready var height_node: LineEdit = find_node("Height");
onready var label_node: LineEdit = find_node("ResLabel");

const CUSTOM_LIST_FILE_PATH: String = "res://addons/ResolutionManager/lists/list_custom.txt";


# Save size in config file and reload the menu:
func _on_Ok_pressed()-> void:
	var label: String = label_node.text;
	var text : String = width_node.text + "x" + height_node.text;
	
	var width: int = int(width_node.text);
	var height: int = int(height_node.text);
	if height == 0 or width == 0 or  label == "":
		var error_dialog = AcceptDialog.new();
		add_child(error_dialog);
		error_dialog.window_title = "Error";
		error_dialog.dialog_text = "Resolution not added because of incomplete\ndetails";
		error_dialog.popup_exclusive = true;
		error_dialog.popup_centered();
		error_dialog.show();
	else:
		config_file.load(CUSTOM_LIST_FILE_PATH);
		config_file.set_value("Custom Resolutions", label, text);
		config_file.save(CUSTOM_LIST_FILE_PATH);
	
		emit_signal("reload");
	
	hide();
	_clear_line_edit_texts();


func _on_Cancel_pressed()-> void:
	hide();
	_clear_line_edit_texts();


func _clear_line_edit_texts()-> void:
	width_node.clear();
	height_node.clear();
	label_node.clear();




