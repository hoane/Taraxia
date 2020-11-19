extends MarginContainer

onready var label = $Content/Label
onready var coin = $Content/RoleCoin

func _ready():
	pass

func set_player_name(player_name: String):
	label.text = player_name

func set_player_color(player_color: Color):
	print("set color %s" % player_color)
	label.set("custom_colors/font_color", player_color)
