extends MarginContainer

export (String) var title

func _ready():
	$Content/Label.text = title

func add_item(node: Node):
	node.set_name("GrabBagItem-%s" % $Content/Grid.get_child_count())
	$Content/Grid.add_child(node)

func get_selected_values() -> Array:
	var ret = []
	for c in $Content/Grid.get_children():
		if c.selected:
			ret.append(c.get_value())
	return ret

func sync_state(id):
	for c in $Content/Grid.get_children():
		c.sync_state(id)