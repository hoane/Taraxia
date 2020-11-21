extends MarginContainer

onready var content = $Content/Content

func _ready():
	pass

func create_remote_player_nodes(n):
	for _i in range(n):
		var node = Global.GamePlayerCoin.instance()
		content.add_child(node)

func set_role_name(index: int, role_name: String):
	var node = content.get_child(index)
	node.coin.set_role_name(role_name)

func set_player(index: int, player_name: String, player_color: Color):
	var node = content.get_child(index)
	node.set_player_name(player_name)
	node.set_player_color(player_color)