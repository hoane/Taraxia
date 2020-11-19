extends Control

var player setget set_player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_player(_player):
	$Info.text = _player["name"]
	player = _player