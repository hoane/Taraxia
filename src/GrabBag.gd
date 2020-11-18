extends MarginContainer

export (String) var title

func _ready():
	$Content/Label.text = title

func add_item(node: Node):
	$Content/Grid.add_child(node)

func remove_item(node: Node) -> int:
	var index = node.get_index()
	$Content/Grid.remove_child(node)
	return index

func set_item_visible(index: int, visible: bool):
	rpc("_set_item_visible", index, visible)

remotesync func _set_item_visible(index: int, visible):
	$Content/Grid.get_child(index).visible = visible

func get_items() -> Array:
	var ret = []
	for c in $Content/Grid.get_children():
		if c.visible:
			ret.append(c)
	return ret