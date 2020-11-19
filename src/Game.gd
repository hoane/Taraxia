extends Control

# Role state:
# [ roles ]
#
# Player state:
# PLAYER: player value
# ATTR: { Attributes }
#
# Attributes:
# ROLE: player role

var role_state
var player_state
var town_state
var local_player_index

func init(_state: Dictionary):
	role_state = _state[Global.ROLE]
	player_state = _state[Global.PLAYER]
	town_state = _state[Global.TOWN]
	assert(player_state.size() + town_state.size() == role_state.size())

onready var remote_players_node = $Margin/Areas/Remote
onready var town_node = $Margin/Areas/Town
onready var local_player_node = $Margin/Areas/Local/LocalPlayer
onready var messages = $Margin/Areas/Local/Messages
onready var self_peer_id = get_tree().get_network_unique_id()

# Called when the node enters the scene tree for the first time.
func _ready():
	local_player_index = get_local_player_index()
	create_game_tree()

func get_local_player_index() -> int:
	for i in range(player_state.size()):
		if player_state[i][Global.ID] == self_peer_id:
			return i
	assert (false)
	return -1

func create_game_tree():
	messages.broadcast_message("Starting Game!")
	town_node.create_town_nodes(town_state.size())
	remote_players_node.create_remote_player_nodes(player_state.size() - 1)
	for i in player_state.size():
		if i != local_player_index:
			remote_players_node.set_player(
				get_remote_player_index(i),
				player_state[i][Global.NAME],
				player_state[i][Global.COLOR]
			)

	local_player_node.set_player(
		player_state[local_player_index][Global.NAME],
		player_state[local_player_index][Global.COLOR]
	)

func get_remote_player_index(index: int) -> int:
	return index if index <= local_player_index else index - 1

# Call on server after create_game_tree is complete on all clients
func server_start_game():
	print("Starting game...")
	server_randomize_roles()

func server_randomize_roles():
	var indices = range(role_state.size())
	indices.shuffle()
	for i in range(player_state.size()):
		rpc("_set_player_role", i, indices.pop_front())
	for i in range(town_state.size()):
		rpc("_set_town_role", i, indices.pop_front())

remotesync func _set_player_role(player_index: int, role_index: int):
	print("Setting player %s to role %s" % [player_index, role_index])
	player_state[player_index][Global.ROLE] = role_index
	if player_index == local_player_index:
		local_player_node.set_role(role_state[role_index][Global.NAME])
	else:
		remote_players_node.set_role(get_remote_player_index(player_index), role_state[role_index][Global.NAME])

remotesync func _set_town_role(town_index: int, role_index: int):
	print("Setting town %s to role %s" % [town_index, role_index])
	town_state[town_index][Global.ROLE] = role_index
	town_node.set_role(town_index, role_state[role_index][Global.NAME])

func assign_roles():
	print("assigning roles...")

