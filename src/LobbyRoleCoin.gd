extends Control

signal pressed(select, index)

var role
var select
var index

func init(_role, _select, _index):
	role = _role
	select = _select
	index = _index


onready var role_label = $Content/RoleLabel
onready var button = $Content/MarginContainer/Button

func _ready():
	role_label.text = role[Global.NAME]

func get_role():
	return role

func set_pressable(is_pressable):
	button.disabled = !is_pressable

func _on_Button_pressed():
	emit_signal("pressed", select, index)
