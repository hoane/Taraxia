extends Control

var role = Global.Role.CREWMATE
var selected = false setget set_selected
var _hover = false
var texture_index = 0

func init(_role, _selected):
	role = _role
	selected = _selected

onready var SelectShader = preload("res://shader/select.shader")
onready var role_label = $Content/RoleLabel
onready var button = $Content/Button

func _ready():
	role_label.text = Global.roles[role][Global.NAME]
	button.material = ShaderMaterial.new()
	button.material.shader = SelectShader
	button.expand = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	button.set_size(Vector2(120, 120))
	button.texture_normal = Global.roles[role][Global.TEXTURE][texture_index]
	update_shader()

func set_selected(_selected: bool):
	assert(get_tree().is_network_server())
	rpc("_set_selected", _selected)

remotesync func _set_selected(_selected: bool):
	print("set sel %s" % _selected)
	selected = _selected
	update_shader()

func set_pressable(pressable: bool):
	button.disabled = !pressable

func get_value():
	return role

func _on_Button_pressed():
	set_selected(!selected)

func update_shader():
	button.material.set_shader_param("mono", !selected)
	if !button.disabled:
		button.material.set_shader_param("highlight", _hover)

func _on_Button_mouse_entered():
	_hover = true
	update_shader()

func _on_Button_mouse_exited():
	_hover = false
	update_shader()

func sync_state(id):
	rpc_id(id, "_set_selected", selected)
