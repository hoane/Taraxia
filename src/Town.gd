extends MarginContainer

onready var content = $Content/Content

func _ready():
	pass

func create_town_nodes(n: int):
	for _i in range(n):
		content.add_child(Global.RoleCoin.instance())

func get_coin(index: int) -> Node: # RoleCoin
	return content.get_child(index)