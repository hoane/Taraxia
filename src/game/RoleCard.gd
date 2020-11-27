extends Node2D

var role = 0

func init(_role: int):
	role = _role

onready var icon = $Icon

func _ready():
	icon.texture = Global.roles[0][Global.TEXTURE]
	icon.modulate = Color(1, 1, 1, 1)

func set_role(_role: int):
	role = _role

func set_spotlight(spotlight):
	if spotlight:
		$AnimationPlayer.play("spotlight")
	else:
		$AnimationPlayer.stop("spotlight")
		icon.modulate = Color(1, 1, 1, 1)

# SERVER

func set_reveal(reveal: bool, reveal_to_id: int):
	if reveal_to_id == 1:
		_set_reveal(reveal)
	else:
		rpc_id(reveal_to_id, "_set_reveal", reveal)

# CLIENT

remote func _set_reveal(reveal: bool):
	if reveal:
		icon.texture = Global.roles[role][Global.TEXTURE]
	else:
		icon.texture = Global.roles[0][Global.TEXTURE]
