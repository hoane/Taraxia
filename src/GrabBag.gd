extends MarginContainer

export (String) var title

func _ready():
	$Content/Label.text = title

func add_item(node: Node):
	$Content/Grid.add_child(node)

func set_all_invisible():
	for c in $Content/Grid.get_children():
		c.visible = false

func set_item_visible(index: int, visible: bool):
	rpc("_set_item_visible", index, visible)
	_set_item_visible(index, visible)

remote func _set_item_visible(index: int, visible):
	$Content/Grid.get_child(index).visible = visible

func sync_all(id):
	assert(get_tree().is_network_server())
	for c in $Content/Grid.get_children():
		rpc_id(id, "_set_item_visible", c.get_index(), c.visible)
		

func get_items() -> Array:
	var ret = []
	for c in $Content/Grid.get_children():
		if c.visible:
			ret.append(c)
	return ret