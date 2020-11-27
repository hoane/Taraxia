extends Node2D

var _awake = true

func _ready():
	modulate = Color(1, 1, 1, 0)


func sleep():
	if _awake:
		_awake = false
		$AnimationPlayer.play("FadeIn")


func wake():
	if !_awake:
		_awake = true
		$AnimationPlayer.play("FadeOut")
