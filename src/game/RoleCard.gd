extends Node2D

var role = 0
var texture_index = 0

func init(_role: int):
	role = _role

onready var icon = $Icon

func _ready():
	icon.set_scale(Vector2(0.1, 0.1))
	icon.modulate = Color(1, 1, 1, 1)
	set_texture(Global.roles[0][Global.TEXTURE][texture_index])

func set_texture(texture):
	var target_size = Vector2(140, 140)
	var tex_size = texture.get_size()
	var size_scale = Vector2(target_size.x / tex_size.x, target_size.y / tex_size.y)
	icon.set_scale(size_scale)
	icon.texture = texture

# SERVER

func set_reveal(reveal: bool, reveal_to_id: int):
	if reveal_to_id == 1:
		_set_reveal(reveal)
	else:
		rpc_id(reveal_to_id, "_set_reveal", reveal)

# CLIENT

remote func _set_reveal(reveal: bool):
	var idx = role if reveal else 0
	set_texture(Global.roles[idx][Global.TEXTURE][texture_index])
