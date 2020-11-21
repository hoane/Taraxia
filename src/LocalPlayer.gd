extends MarginContainer

onready var player = $Content/Player

func _ready():
	pass

func set_player(player_name: String, player_color: Color):
	player.set_player_name(player_name)
	player.set_player_color(player_color)

func set_role_name(role_name: String):
	player.coin.set_role_name(role_name)

