extends Control

signal pressed(node)

var role

func init(_role):
	role = _role

onready var role_label = $Content/RoleLabel
onready var button = $Content/MarginContainer/Button

func _ready():
	print(role)
	role_label.text = role["name"]

func get_role():
	return role

func set_pressable(is_pressable):
	button.disabled = !is_pressable

func set_role_visible(is_visible):
	role_label.visible = is_visible

func _on_Button_pressed():
	emit_signal("pressed", self)
