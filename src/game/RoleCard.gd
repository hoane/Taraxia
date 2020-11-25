extends Node2D

enum {
	AWAKE = 1,
	ASLEEP = 0,
	OTHER = -1
}

var _role = 0
var _reveal = false
var _awake = AWAKE

onready var name_label = $Content/Name
onready var icon = $Content/Icon
onready var asleep_label = $Content/Asleep
onready var awake_label = $Content/Awake

const off_color = Color(0.09, 0.09, 0.33)
const awake_color = Color(1, 0.23, 0.23)
const asleep_color = Color(0.47, 0.76, 0.95)

func _ready():
	icon.modulate = Color(1, 1, 1, 1)
	update_gui()

func update_gui():
	if _reveal:
		icon.texture = Global.roles[_role][Global.TEXTURE]
	else:
		icon.texture = Global.roles[0][Global.TEXTURE]

	match _awake:
		AWAKE:
			awake_label.set("custom_colors/font_color", awake_color)
			asleep_label.set("custom_colors/font_color", off_color)
		ASLEEP:
			awake_label.set("custom_colors/font_color", off_color)
			asleep_label.set("custom_colors/font_color", asleep_color)
		OTHER:
			awake_label.set("custom_colors/font_color", off_color)
			asleep_label.set("custom_colors/font_color", off_color)

func set_awake(awake):
	_awake = awake
	update_gui()

func set_role(role: int):
	_role = role
	update_gui()

func set_reveal(reveal):
	_reveal = reveal
	update_gui()

func set_spotlight(spotlight):
	if spotlight:
		$AnimationPlayer.play("spotlight")
	else:
		$AnimationPlayer.stop("spotlight")
		icon.modulate = Color(1, 1, 1, 1)



func set_info(player_name: String, player_color: Color):
	name_label.text = player_name
	name_label.set("custom_colors/font_color", player_color)
