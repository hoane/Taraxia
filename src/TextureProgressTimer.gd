extends Node2D

signal progress_completed

export (int) var role = 10
export (Color, RGB) var progress_color = Color(1, 1, 1)
export (float) var timeout = 30

func init(_role, _color, _timeout = 30):
	role = _role
	progress_color = _color
	timeout = _timeout

func _ready():
	$Progress.modulate = progress_color
	$Icon.texture = Global.roles[role][Global.TEXTURE]

func start():
	$Tween.interpolate_property(
		$Progress,
		"value",
		1000,
		0,
		timeout
	)
	$Tween.start()

func _on_Progress_value_changed(value: float):
	if value == 0:
		emit_signal("progress_completed") 
