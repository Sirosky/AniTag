tool
extends EditorPlugin

# Resolution menu button:
var resolution_menu_btn: MenuButton = null;

# Add menu button to canvas editor:
func _enter_tree()-> void:
	resolution_menu_btn = preload("ResolutionButton.tscn").instance();
	add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU, resolution_menu_btn);


# Remove menu button from canvas editor:
func _exit_tree()-> void:
	remove_control_from_container(CONTAINER_CANVAS_EDITOR_MENU, resolution_menu_btn);
	resolution_menu_btn.queue_free();


# Plugin name:
func get_plugin_name()-> String: 
	return "Resolution Manager";