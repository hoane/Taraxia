extends Control

signal pressed(node)

onready var role_label = $Content/Label
onready var button = $Content/Button
onready var unknown_icon = load("res://assets/icons/unknown.png")

func _ready():
	button.disabled = true
	button.texture_normal = unknown_icon

func set_role(role: int):
	role_label.text = Global.roles[role][Global.NAME]

func set_disabled(disabled: bool):
	button.disabled = disabled

func hide_role():
	button.texture_normal = unknown_icon

func reveal_role():
	pass

func _on_Button_pressed():
	emit_signal("pressed", self)
