extends Control

var window_size = Vector2()

func _ready():
	$Content/Content/Fullscreen.pressed = OS.window_fullscreen
	window_size = OS.window_size

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_parent().remove_child(self)

func _on_Fullscreen_toggled(button_pressed: bool):
	if button_pressed:
		window_size = OS.window_size
	else:
		OS.window_size = window_size
	
	OS.window_fullscreen = button_pressed
	OS.window_borderless = button_pressed

func _on_Cancel_pressed():
	get_parent().remove_child(self)