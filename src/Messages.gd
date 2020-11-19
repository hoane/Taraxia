extends MarginContainer

const broadcast_color = Color.gold
const message_color = Color.skyblue

onready var message_label = $Content/Content/RichTextLabel

func _ready():
	pass

func broadcast_message(message):
	rpc("_broadcast_message", message)

remotesync func _broadcast_message(message):
	message_label.push_color(broadcast_color)
	message_label.add_text("• %s\n" % message)
	message_label.pop()

remote func send_local_message(message: String):
	message_label.push_color(message_color)
	message_label.add_text("• %s\n" % message)
	message_label.pop()

func send_message(id: int, message: String):
	if id == get_tree().get_network_unique_id():
		send_local_message(message)
	else:
		rpc_id(id, "send_local_message", message)