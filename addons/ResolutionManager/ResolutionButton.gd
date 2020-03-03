tool
extends MenuButton

# Text files paths:
const LIST_PATH: String = "res://addons/ResolutionManager/lists/list_";
const TOOLTIP_JSON_PATH: String = "res://addons/ResolutionManager/stretch_settings_tooltip.json";
const MENU_BUTTON_TOOLTIP = "Quickly set base/test resolutions"

# Canvas editor menu and submenu popups:
var menu_popup: PopupMenu = null;
var stretch_settings_submenu: PopupMenu = null;
var list_submenu: PopupMenu = null;

# Window dialog:
var set_res_window: Node = null;
var option_btn: Node = null;
var custom_res_window: Node = null;

# Data dictionaries:
var resolution_data: Dictionary = {};
var json_dict: Dictionary = {};

# Submenus idx:
var list_idx: int = 0;
var stretch_idx: int = 0;

var config_file: ConfigFile = null;
var current_list: String = LIST_PATH + "basic.txt";


# Init:
func _enter_tree()-> void:
	# Init Set base resolution window:
	set_res_window = preload("BaseResWindow.tscn").instance();
	option_btn = set_res_window.find_node("OptionButton");
	add_child(set_res_window);
	
	# Init custom resolution window:
	custom_res_window = preload("CustomResWindow.tscn").instance();
	custom_res_window.connect("reload", self, "load_main_menu")
	add_child(custom_res_window);
	
	# Parse JSON file:
	var file: File = File.new();
	file.open(TOOLTIP_JSON_PATH, file.READ);
	json_dict = parse_json(file.get_as_text());
	file.close();
	
	# Connect index_pressed signal to switch resloution:
	menu_popup = get_popup();
	menu_popup.connect("index_pressed", self, "_on_menu_popup_index_pressed");
	
	# Fill popup menu and resolution data dictionary:
	load_main_menu();
	hint_tooltip = MENU_BUTTON_TOOLTIP;


# Free:
func _exit_tree()-> void:
	# Clear popup menu and dictionaries:
	resolution_data.clear();
	json_dict.clear();

	# Free menus and popups:
	if menu_popup:
		menu_popup.clear();
		menu_popup.queue_free();
	if stretch_settings_submenu:
		stretch_settings_submenu.queue_free();
	if list_submenu:
		list_submenu.queue_free();
	if set_res_window:
		set_res_window.queue_free();
	if custom_res_window:
		custom_res_window.queue_free();


# Fill popup menu and resolution data dictionary:
func load_main_menu()-> void:
	if not menu_popup or not option_btn:
		return;
		
	# Load current list:
	config_file = ConfigFile.new();
	var is_loaded: = config_file.load(current_list);
	if is_loaded != OK:
		return;
	
	# Clear when reloading:
	resolution_data = {};
	
	if menu_popup:
		menu_popup.clear();
	if option_btn:
		option_btn.clear();
	
	# Load submenus:
	load_stretch_settings_submenu();
	load_list_submenu();
	
	# Load window item:
	menu_popup.add_item("Set Base Resolution");
	menu_popup.add_item("Add Custom Resolution");
	menu_popup.add_separator();
	menu_popup.set_item_disabled(3, not(list_idx == 6));
	
	# Load test resolutions:
	for section in config_file.get_sections():
		menu_popup.add_separator(section);
		
		for key in config_file.get_section_keys(section):
			var value = config_file.get_value(section,key).split("x");
			var width = value[0];
			var height = value[1];
			var text = key + "    (" + width + "x" + height +")";
			
			resolution_data[text] = {
				"label": key,
				"width": width,
				"height": height
			};
			
			menu_popup.add_item(text);
			option_btn.add_item(text);
			
		option_btn.add_separator();
	
	var count: int = option_btn.get_item_count();
	option_btn.remove_item(count-1);


# Create stretch settings submenu:
func load_stretch_settings_submenu()-> void:
	# Clear on reload:
	if stretch_settings_submenu:
		menu_popup.remove_child(stretch_settings_submenu);
		stretch_settings_submenu.clear();
		stretch_settings_submenu.queue_free();
	
	# Create new:
	stretch_settings_submenu = PopupMenu.new();
	stretch_settings_submenu.name = "stretch_settings";
	stretch_settings_submenu.connect("index_pressed", self, 
				"_on_stretch_settings_submenu_index_pressed");
	
	# Add items: 
	var a: Array = ["Scrn Fill", "One Ratio", "GUI", "Platformer", "Expand"];
	var b: Array = ["2D, ", "VP, "];
	var c: Array = ["ignore", "keep", "kp_w", "kp_ht", "expand"];
	
	var text: String = "Full Ctrl: disable, ignore";
	for i in range(11):
		if i != 0 and i < 6:
			text = a[i-1] + ": " + b[0] + c[i-1];
		elif i >= 6:
			text = "Pixel, " + a[fmod(i-1, 5)] + ": " + b[1] + c[fmod(i-1, 5)];
		
		stretch_settings_submenu.add_radio_check_item(text, i);
		stretch_settings_submenu.set_item_tooltip(i, json_dict[String(i)]);
	
	# Get current and check it:
	var mode = String(ProjectSettings.get_setting("display/window/stretch/mode"));
	var aspect = String(ProjectSettings.get_setting("display/window/stretch/aspect"));
	var aspects: Array = ["ignore", "keep", "keep_width", "keep_height", "expand"];
	if mode == "disabled":
		stretch_idx = 0;
	elif mode == "2d":
		stretch_idx = aspects.find(aspect) + 1;
	elif mode == "viewport":
		stretch_idx = aspects.find(aspect) + 6;
	
	update_radio_group_check_state(stretch_settings_submenu, stretch_idx);
	
	# Attach submenu:
	menu_popup.add_child(stretch_settings_submenu);
	menu_popup.add_submenu_item("Stretch Settings", "stretch_settings");


# Create list submenu:
func load_list_submenu()-> void:
	# Clear on reload:
	if list_submenu:
		menu_popup.remove_child(list_submenu);
		list_submenu.clear();
		list_submenu.queue_free();
	
	# Create new:
	list_submenu = PopupMenu.new();
	list_submenu.name = "list_submenu";
	list_submenu.connect("index_pressed", self, "_on_list_submenu_index_pressed");
	
	# Add items:
	var array: Array = ["Basic", "IPhone", "Ipad", "Android", "Most Used", "Large", "Custom"];
	for i in range(array.size()):
		list_submenu.add_radio_check_item(array[i] + " List", i);
	
	# Check one:
	update_radio_group_check_state(list_submenu, list_idx);
	
	# Attach submenu:
	menu_popup.add_child(list_submenu);
	menu_popup.add_submenu_item("Resolution List", "list_submenu");


# Check radio btn in a radio group:
func update_radio_group_check_state(menu: PopupMenu, idx: int)-> void:
	if not menu:
		return;
	
	var item_count: int = menu.get_item_count();
	for i in range(item_count):
		if i == idx:
			if not menu.is_item_checked(i):
				menu.toggle_item_checked(i);
		else:
			if menu.is_item_checked(i):
				menu.toggle_item_checked(i);


# Event: main menu item pressed:
func _on_menu_popup_index_pressed(idx: int)-> void:
	if not menu_popup:
		return;
	
	var key := menu_popup.get_item_text(idx);
	if key == "Set Base Resolution":
		set_res_window.show();
		set_res_window.popup_centered();
	
	elif key == "Add Custom Resolution":
		custom_res_window.show();
		custom_res_window.popup_centered();
	
	else:
		var width: int = resolution_data[key]["width"];
		var height: int = resolution_data[key]["height"];
		
		ProjectSettings.set_setting("display/window/size/test_width", width);
		ProjectSettings.set_setting("display/window/size/test_height", height);
		ProjectSettings.save();
		
		text = key;


# Event: stretch settings item pressed:
func _on_stretch_settings_submenu_index_pressed(idx: int)-> void:
	var array: Array = ["ignore", "keep", "keep_width", "keep_height", "expand"];
	var mode = "disabled";
	var aspect = "ignore";
	if idx != 0 and idx < 6:
		mode = "2d";
		aspect = array[idx-1];
	elif idx >= 6:
		mode = "viewport";
		aspect = array[fmod(idx-1, 5)];

	update_radio_group_check_state(stretch_settings_submenu, idx);
	ProjectSettings.set_setting("display/window/stretch/mode", mode);
	ProjectSettings.set_setting("display/window/stretch/aspect", aspect);
	ProjectSettings.save();
	stretch_idx = idx;


# Event: main menu item pressed:
func _on_list_submenu_index_pressed(idx: int)-> void:
	if idx == 0:
		current_list = LIST_PATH + "basic.txt";
	elif idx == 1:
		current_list = LIST_PATH + "iphone.txt";
	elif idx == 2:
		current_list = LIST_PATH + "ipad.txt";
	elif idx == 3:
		current_list = LIST_PATH + "android.txt";
	elif idx == 4:
		current_list = LIST_PATH + "mostused.txt";
	elif idx == 5:
		current_list = LIST_PATH + "large.txt";
	elif idx == 6:
		current_list = LIST_PATH + "custom.txt";
	
	update_radio_group_check_state(list_submenu, idx);
	list_idx = idx;
	
	# Reload:
	load_main_menu();


