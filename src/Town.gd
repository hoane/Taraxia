extends MarginContainer

onready var content = $Content/Content

func _ready():
	pass

func create_town_nodes(n: int):
	for _i in range(n):
		content.add_child(Global.GamePlayerCoin.instance())

func get_player(index: int) -> Node: # GamePlayerCoin
	return content.get_child(index)