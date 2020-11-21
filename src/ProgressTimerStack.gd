extends Control

signal progress_completed(index)

var stack_items = []
var active_index = -1

func _ready():
	pass

func start_next():
	active_index += 1
	start(active_index)

func start(index):
	active_index = index
	$Stack/Items.get_child(index).start()

func add_progress(role: int):
	var index = $Stack/Items.get_child_count()
	print("adding progress bar %s for %s" % [index, role])
	var node = Global.TextureProgressTimer.instance()
	node.init(role, Color(1, 0.5, 0.5))
	node.position = $Stack/Hints.get_child(index).position

	node.connect("progress_completed", self, "_on_progress_completed", [index])
	$Stack/Items.add_child(node)

func slide_out(index):
	var node = $Stack/Items.get_child(index)
	$Tween.interpolate_property(
		node,
		"position:x",
		node.position.x,
		node.position.x + 400,
		1.5,
		Tween.TRANS_BACK,
		Tween.EASE_IN_OUT
	)
	$Tween.start()
	yield($Tween, "tween_all_completed")

func advance_items():
	$Tween.interpolate_property(
		$Stack/Items,
		"position:y",
		$Stack/Items.position.y,
		$Stack/Items.position.y - 130,
		1,
		Tween.TRANS_CUBIC,
		Tween.EASE_IN_OUT
	)
	$Tween.start()
	yield($Tween, "tween_all_completed")

func _on_progress_completed(index):
	emit_signal("progress_completed", index)
	yield(slide_out(index), "completed")
	yield(advance_items(), "completed")

