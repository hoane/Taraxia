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
onready var timer_stack = $ProgressTimerStack
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

func player_role_attr(player_index, attr_name):
	return Global.roles[role_state[player_state[player_index][Global.ROLE]]][attr_name]

func role_attr(role_index, attr_name):
	return Global.roles[role_state[role_index]][attr_name]

func create_game_tree():
	town_node.create_town_nodes(town_state.size())
	remote_players_node.create_remote_player_nodes(player_state.size() - 1)
	for i in player_state.size():
		if i != local_player_index:
			var player = remote_players_node.get_player(get_remote_player_index(i))
			player.set_info(
				player_state[i][Global.NAME],
				player_state[i][Global.COLOR]
			)

	local_player_node.get_player().set_info(
		player_state[local_player_index][Global.NAME],
		player_state[local_player_index][Global.COLOR]
	)

	for i in Global.night_wake_order:
		if role_state.has(i):
			timer_stack.add_progress(i)

func get_remote_player_index(index: int) -> int:
	return index if index <= local_player_index else index - 1

# Call on server after create_game_tree is complete on all clients
func server_start_game():
	print("Starting Game")
	messages.broadcast_message("Starting Game!")
	server_randomize_roles()

func server_randomize_roles():
	var indices = range(role_state.size())
	indices.shuffle()
	rpc("_set_role_shuffle", indices)

remotesync func _set_role_shuffle(indices):
	print("setting randomized roles")
	for i in range(player_state.size()):
		var role_index = indices.pop_front()
		_set_player_role(i, role_index)
		messages.send_message(player_state[i][Global.ID], "You are the %s.\n  %s\n  %s" % [
			role_attr(role_index, Global.NAME),
			role_attr(role_index, Global.DESCRIPTION),
			role_attr(role_index, Global.INSTRUCT),
		])
	for i in range(town_state.size()):
		_set_town_role(i, indices.pop_front())


remotesync func message_player_role():
	messages.send_local_message("You are the %s.\n  %s\n  %s" % [
		player_role_attr(local_player_index, Global.NAME),
		player_role_attr(local_player_index, Global.DESCRIPTION),
		player_role_attr(local_player_index, Global.INSTRUCT),
	])

func _set_player_role(player_index: int, role_index: int):
	print("Setting player %s to role %s" % [player_index, role_index])
	player_state[player_index][Global.ROLE] = role_index
	if player_index == local_player_index:
		local_player_node.get_player().get_coin().set_role(role_state[role_index])
	else:
		var coin = remote_players_node.get_player(get_remote_player_index(player_index)).get_coin()
		coin.set_role(role_state[role_index])

func _set_town_role(town_index: int, role_index: int):
	print("Setting town %s to role %s" % [town_index, role_index])
	town_state[town_index][Global.ROLE] = role_index
	town_node.get_coin(town_index).set_role(role_state[role_index])

func assign_roles():
	print("assigning roles...")

