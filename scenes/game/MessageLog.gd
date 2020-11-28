extends RichTextLabel

const broadcast_color = Color.gold
const message_color = Color.skyblue

func _ready():
	pass

func broadcast_message(message):
	rpc("_broadcast_message", message)

remotesync func _broadcast_message(message):
	push_color(broadcast_color)
	add_text("• %s\n" % message)
	pop()

remote func send_local_message(message: String):
	push_color(message_color)
	add_text("• %s\n" % message)
	pop()

func send_message(id: int, message: String):
	if id == get_tree().get_network_unique_id():
		send_local_message(message)
	else:
		rpc_id(id, "send_local_message", message)