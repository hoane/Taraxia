extends Control

signal pressed(node)

onready var role_label = $Content/RoleLabel
onready var button = $Content/MarginContainer/Button

func _ready():
	button.disabled = true

func set_role_name(role_name: String):
	role_label.text = role_name

func set_disabled(disabled: bool):
	button.disabled = disabled

func set_role_visible(role_visible: bool):
	role_label.visible = role_visible

func _on_Button_pressed():
	emit_signal("pressed", self)
