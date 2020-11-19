extends Node

var current_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	open_start_menu()

func open_start_menu():
	current_scene = Global.StartMenu.instance()
	add_child(current_scene)
