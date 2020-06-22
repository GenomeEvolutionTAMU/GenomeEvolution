extends Control

signal go_to_game(settings, cell_string)

onready var transposon = get_node("CharTE")
onready var cell_selection = get_node("CellSelection")
onready var settings_menu = get_node("Panel/Settings")
onready var description = get_node("Description")
onready var resources = get_node("ResourceSettings")

# Called when the node enters the scene tree for the first time.
func _ready():
	transposon.set_color(Color.red)
	_on_CellSelection_cell_changed(cell_selection.get_cell_string())
	pass # Replace with function body.


func _on_GoToGame_pressed():
	settings_menu.get_final_settings()
	resources.update_global_settings()
	
	Game.resource_mult = Settings.resource_consumption_rate()
	Game.current_cell_string = cell_selection.get_cell_string()

	Unlocks.unlock_override = Settings.unlock_everything()
	Settings.apply_richness()
	Settings.populate_cell_texture_paths()
	Settings.update_seed()
#	Settings.save_all_settings()
	get_tree().change_scene("res://Scenes/MainMenu/Goal.tscn")
	pass # Replace with function body.


func _on_CellSelection_cell_changed(cell_string):
	description.bbcode_text = "%s: %s" % [Settings.settings["cells"][cell_string]["name"], Settings.settings["cells"][cell_string]["description"]]
	pass # Replace with function body.


func _on_Save_pressed():
	resources.update_global_settings()
	settings_menu.get_final_settings()
	settings_menu.update_global_settings()
	
	Settings.save_all_settings()
	pass # Replace with function body.


func _on_Load_pressed():
	Settings.load_all_settings(false)
	resources.reload()
	settings_menu.reload()
	pass # Replace with function body.
