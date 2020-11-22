extends MarginContainer

onready var content = $Content/Content

func _ready():
	pass

func create_remote_player_nodes(n):
	for _i in range(n):
		var node = Global.GamePlayerCoin.instance()
		content.add_child(node)

func get_player(index: int) -> Node: # GamePlayerCoin
	return content.get_child(index)