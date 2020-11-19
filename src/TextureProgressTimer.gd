extends Control

export (float) var time 

func _ready():
	start_timer()

func start_timer():
	$Content/AnimationPlayer.play("ProgressBar")

func set_texture(texture):
	$Content/Icon.texture = texture
