extends Control

signal lobby_start_button(players, roles)

const ref_item = preload("res://tex/iconatlas.tres")

var initial_unselected_roles = [
	Global.Role.VILLAGER,
	Global.Role.VILLAGER,
	Global.Role.VILLAGER,
	Global.Role.VILLAGER,
	Global.Role.VILLAGER,
	Global.Role.WEREWOLF,
	Global.Role.WEREWOLF,
	Global.Role.WEREWOLF
]

var is_server
var player_labels = {}
var role_state = {}

func init(_is_server):
	is_server = _is_server

onready var remote_tree = $Margin/Content/Remote
onready var local_tree = $Margin/Content/Local/Player
onready var start_button = $Margin/Content/Local/StartButton
onready var item_list = $Margin/Content/Roles/ItemList
onready var selected_bag = $Margin/Content/Roles/Selected
onready var unselected_bag = $Margin/Content/Roles/Unselected
onready var peer_id = get_tree().get_network_unique_id()

# Called when the node enters the scene tree for the first time.
func _ready():
	start_button.visible = is_server

	for i in range(len(initial_unselected_roles)):
		var r = initial_unselected_roles[i]
		var sel_coin = Global.RoleCoin.instance()
		var unsel_coin = Global.RoleCoin.instance()
		sel_coin.init(Global.roles[r])
		unsel_coin.init(Global.roles[r])

		sel_coin.connect("pressed", self, "_on_role_button_pressed")
		unsel_coin.connect("pressed", self, "_on_role_button_pressed")
		selected_bag.add_item(sel_coin)
		unselected_bag.add_item(unsel_coin)
		role_state[i] = {
			"sel_node": sel_coin,
			"unsel_node": unsel_coin,
			"selected": false
		}

func add_player(player):
	var node = Global.LobbyPlayerLabel.instance()
	node.init(player)
	var id = player["peer_id"]
	player_labels[id] = node
	if peer_id == id:
		local_tree.add_child(node)
	else:
		remote_tree.add_child(node)

func remove_player(id):
	player_labels[id].queue_free()
	player_labels.erase(id)

func get_role_coin_index(node):
	for i in range(0, len(role_state)):
		if role_state[i]["node"] == node:
			return i
	return -1

func _on_role_button_pressed(node):
	if !is_server:
		return
	var index = get_role_coin_index(node)

remotesync func _set_role_node_selected(node_index, select):
	print("rpc set for node at %s with selected=%s" % [node_index, select])
	var node = role_state[node_index]["node"]
	node.get_parent().remove_child(node)

func set_selected_roles(id):
	if !is_server:
		return

func get_selected_roles() -> Array:
	var ret = []
	return ret

func get_players() -> Dictionary:
	var ret = {}
	for k in player_labels.keys():
		ret[k] = player_labels[k].get_player()
	return ret

func _on_StartButton_pressed():
	emit_signal("lobby_start_button", get_players(), get_selected_roles())
