extends Node2D

signal progress_completed

export (int) var role = 0
export (Color, RGB) var progress_color = Color(1, 1, 1)
export (float) var timeout = 30

func init(_role, _color, _timeout = 30):
	role = _role
	progress_color = _color
	timeout = _timeout

func _ready():
	$Progress.tint_progress = progress_color
	$Icon.texture = Global.roles[role][Global.TEXTURE][0]
	var target_size = Vector2(100, 100)
	var tex_size = $Icon.texture.get_size()
	var size_scale = Vector2(target_size.x / tex_size.x, target_size.y / tex_size.y)
	$Icon.set_scale(size_scale)

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
