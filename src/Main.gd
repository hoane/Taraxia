extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(preload("res://scenes/ParallaxStarfield.tscn").instance())

func open_start_menu():
	add_child(Global.StartMenu.instance())

func _process(_delta):
	if get_node("StartMenu") == null:
		open_start_menu()
