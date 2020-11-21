extends Control

signal pressed(select, index)

var role = Global.Role.CREWMATE
var select = false
var index = -1

func init(_role, _select, _index):
	role = _role
	select = _select
	index = _index

onready var role_label = $Content/RoleLabel
onready var button = $Content/Button

func _ready():
	role_label.text = Global.roles[role][Global.NAME]
	if select:
		button.texture_normal = Global.roles[role][Global.TEXTURE]
		button.texture_hover = Global.roles[role][Global.TEXTURE_MONO]
	else:
		button.texture_hover = Global.roles[role][Global.TEXTURE]
		button.texture_normal = Global.roles[role][Global.TEXTURE_MONO]

func set_pressable(is_pressable):
	button.disabled = !is_pressable

func _on_Button_pressed():
	emit_signal("pressed", select, index)
