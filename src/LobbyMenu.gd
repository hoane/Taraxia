extends Control

signal lobby_start_button(players, roles)

const ref_item = preload("res://tex/iconatlas.tres")

var is_server
var player_labels = {}

func init(_is_server):
	is_server = _is_server

onready var remote_tree = $Margin/Content/Remote
onready var local_tree = $Margin/Content/Local/Player
onready var start_button = $Margin/Content/Local/StartButton
onready var selected_bag = $Margin/Content/Roles/Selected
onready var unselected_bag = $Margin/Content/Roles/Unselected
onready var peer_id = get_tree().get_network_unique_id()

# Called when the node enters the scene tree for the first time.
func _ready():
	start_button.visible = is_server

	var sel_coin

	for i in range(Global.available_roles.size()):
		var r = Global.available_roles[i]
		sel_coin = Global.LobbyRoleCoin.instance()
		var unsel_coin = Global.LobbyRoleCoin.instance()
		sel_coin.init(Global.roles[r], true, i)
		unsel_coin.init(Global.roles[r], false, i)

		sel_coin.connect("pressed", self, "_on_role_button_pressed")
		unsel_coin.connect("pressed", self, "_on_role_button_pressed")
		selected_bag.add_item(sel_coin)
		unselected_bag.add_item(unsel_coin)
		sel_coin.button.disabled = !is_server
		unsel_coin.button.disabled = !is_server

	selected_bag.rect_min_size = Vector2(5 * sel_coin.rect_size.x, 2 * sel_coin.rect_size.y)
	unselected_bag.rect_min_size = Vector2(5 * sel_coin.rect_size.x, 2 * sel_coin.rect_size.y)
	selected_bag.set_all_invisible()

func add_player(player):
	var node = Global.LobbyPlayerLabel.instance()
	node.player = player
	var id = player["peer_id"]
	player_labels[id] = node
	if peer_id == id:
		local_tree.add_child(node)
	else:
		remote_tree.add_child(node)

func remove_player(id):
	player_labels[id].queue_free()
	player_labels.erase(id)

func _on_role_button_pressed(select, index):
	if !is_server:
		return

	selected_bag.set_item_visible(index, !select)
	unselected_bag.set_item_visible(index, select)

func set_selected_roles(id):
	assert (is_server)
	selected_bag.sync_all(id)
	unselected_bag.sync_all(id)

func get_selected_roles() -> Array:
	var ret = []
	for c in selected_bag.get_items():
		ret.append(c.get_role())
	return ret

func get_players() -> Dictionary:
	var ret = {}
	for k in player_labels.keys():
		ret[k] = player_labels[k].player
	return ret

func _on_StartButton_pressed():
	var roles = get_selected_roles()
	var players = get_players()
	if roles.size() > players.size():
		emit_signal("lobby_start_button", get_players(), get_selected_roles())
