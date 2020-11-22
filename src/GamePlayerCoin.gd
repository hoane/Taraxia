extends MarginContainer

onready var label = $Content/Label
onready var coin = $Content/RoleCoin

func _ready():
	pass

func set_info(player_name: String, player_color: Color):
	label.text = player_name
	label.set("custom_colors/font_color", player_color)

func get_coin(): # RoleCoin
	return coin