extends MarginContainer

onready var content = $Content/Content

func _ready():
	pass

func create_town_nodes(n: int):
	for _i in range(n):
		content.add_child(Global.RoleCoin.instance())

func set_role(index: int, role_name: String):
	var node = content.get_child(index)
	node.set_role_name(role_name)