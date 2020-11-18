extends Control

var player_name
var player_color
var role_coin

func init(_player_name, _player_color):
	player_name = _player_name
	player_color = _player_color

onready var name_label = $Content/PlayerName
onready var coin_parent = $Content/Control

func _ready():
	name_label.text = player_name
	name_label.add_color_override("font_color", player_color)

func set_role_coin(node):
	coin_parent.add_child(node)

func get_role_coin():
	return coin_parent.get_child(0)
