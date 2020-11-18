extends Node

var current_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	open_start_menu()

func open_start_menu():
	current_scene = Global.StartMenu.instance()
	current_scene.connect("start_lobby", self, "_on_StartMenu_start_lobby")
	current_scene.connect("join_lobby", self, "_on_StartMenu_join_lobby")
	current_scene.connect("open_options", self, "_on_StartMenu_open_options")
	add_child(current_scene)
