extends Control

signal lobby_start_button(players, roles)

const ref_item = preload("res://tex/iconatlas.tres")

var is_server
var player_labels = {}

func init(_is_server):
	is_server = _is_server

onready var remote_tree = $Margin/Content/Content/Players/Remote
onready var local_tree = $Margin/Content/Content/Players/Local
onready var start_button = $Margin/Content/StartButton
onready var selected_bag = $Margin/Content/Content/Roles/Selected
onready var peer_id = get_tree().get_network_unique_id()

# Called when the node enters the scene tree for the first time.
func _ready():
	start_button.visible = is_server

	for i in range(Global.available_roles.size()):
		var r = Global.available_roles[i]
		var lobby_coin = Global.LobbyRoleCoin.instance()
		lobby_coin.init(r, false)

		selected_bag.add_item(lobby_coin)
		lobby_coin.set_pressable(is_server)

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

func get_players() -> Dictionary:
	var ret = {}
	for k in player_labels.keys():
		ret[k] = player_labels[k].player
	return ret

func sync_state(id):
	selected_bag.sync_state(id)

func _on_StartButton_pressed():
	var roles = selected_bag.get_selected_values()
	var players = get_players()
	if roles.size() == players.size() + 3:
		emit_signal("lobby_start_button", players, roles)
