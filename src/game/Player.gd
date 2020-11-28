extends Node

const off_color = Color(0.09, 0.09, 0.33)
const awake_color = Color(1, 0.23, 0.23)
const asleep_color = Color(0.47, 0.76, 0.95)

var id: int = 1
var player_name: String = "test"
var initial_role: int = 0
var role: Node = null
var position: Vector2 setget set_position
var sleeping = false

func init(_id: int, _player_name: String):
	id = _id
	player_name = _player_name

onready var badge = $Badge
onready var name_label = $Badge/Name
onready var asleep_label = $Badge/Asleep
onready var awake_label = $Badge/Awake
onready var spotlight = $Badge/Spotlight
onready var spotlight_mat
onready var role_card_pos = $Badge/RoleCardPosition

func _ready():
	var mat = spotlight.get_material().duplicate(true)
	spotlight.set_material(mat)
	name_label.text = player_name

func set_position(_position: Vector2):
	position = _position
	badge.position = _position

func get_role_card_position() -> Vector2:
	return badge.position + role_card_pos.position

# SERVER

func set_spotlight(visible_to: int, spotlight: bool):
	if visible_to == 1:
		_set_spotlight(spotlight)
	else:
		rpc_id(visible_to, "_set_spotlight", spotlight)

func set_sleep(visible_to: int, sleep: bool):
	rpc("_set_sleep", sleep)
	if visible_to == 1:
		_set_sleep(sleep)
	else:
		rpc_id(id, "_set_sleep", sleep)

func set_sleep_overlay(sleep: bool):
	if id == 1:
		_set_sleep_overlay(sleep)
	else:
		rpc_id(id, "_set_sleep_overlay", sleep)

# CLIENT

remote func _set_spotlight(spotlight):
	spotlight_mat.set_shader_param("spotlight", spotlight)

remote func _set_sleep(sleep: bool):
	if sleep:
		asleep_label.set("custom_colors/font_color", asleep_color)
		awake_label.set("custom_colors/font_color", off_color)
	else:
		asleep_label.set("custom_colors/font_color", off_color)
		awake_label.set("custom_colors/font_color", awake_color)

remote func _set_sleep_overlay(sleep: bool):
	if sleep == sleeping:
		return
	sleeping = sleep
	if sleep:
		$AsleepOverlay.sleep()
	else:
		$AsleepOverlay.wake()

