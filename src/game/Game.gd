extends Control

enum {
	RANDOMIZE
}

enum {
	AWAKE = 1,
	ASLEEP = 0,
	OTHER = -1
}

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
var sync_collect = {}

func init(_state: Dictionary):
	role_state = _state[Global.ROLE]
	player_state = _state[Global.PLAYER]
	town_state = _state[Global.TOWN]
	assert(player_state.size() + town_state.size() == role_state.size())

onready var remote_players_node = $Margin/Areas/Remote
onready var town_node = $Margin/Areas/Town
onready var local_player_node = $Margin/Areas/Local/LocalPlayer
onready var messages = $Margin/Areas/Local/Messages
onready var timer_stack = $Overlay/ProgressTimerStack
onready var asleep_overlay = $Overlay/AsleepOverlay
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
	for i in town_state.size():
		town_node.get_player(i).set_info("", Color.white)
		town_node.get_player(i).set_awake(OTHER)
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

	var progress_node = Global.TextureProgressTimer.instance()
	progress_node.init(0, Color(1, 1, 1), 5)
	timer_stack.add_progress(progress_node)
	for i in Global.night_wake_order:
		if role_state.has(i):
			# connect current role to previous node
			if get_tree().is_network_server():
				progress_node.connect("progress_completed", self, "_end_phase", [i])
			progress_node = Global.TextureProgressTimer.instance()
			progress_node.init(i, Color(1, 1, 1), 5)
			timer_stack.add_progress(progress_node)


func get_players_with_initial_role(role: int) -> Array:
	var ret = []
	for i in player_state.size():
		var role_index = player_state[i][Global.INITIAL_ROLE]
		if role_state[role_index] == role:
			ret.append(i)
	return ret

func _end_phase(next_role: int):
	for i in player_state.size():
		set_player_sleep(i, ASLEEP)
	yield(get_tree().create_timer(1.5), "timeout")
	start_role_action(next_role)

func start_role_action(role: int):
	assert(get_tree().is_network_server())
	print("Starting role action of %s" % [Global.roles[role][Global.NAME]])
	var role_player_indices = get_players_with_initial_role(role)
	for i in role_player_indices:
		messages.send_message(player_state[i][Global.ID], Global.roles[role][Global.INSTRUCT])

	match role:
		Global.Role.HOLOGRAM:
			pass
		Global.Role.ALIEN:
			for i in role_player_indices:
				set_player_sleep(i, AWAKE)
		Global.Role.OFFICER:
			for i in role_player_indices:
				set_player_sleep(i, AWAKE)
			var aliens = get_players_with_initial_role(Global.Role.ALIEN)
			for i in aliens:
				set_player_spotlight(i, true)
		Global.Role.CLONE:
			for i in role_player_indices:
				set_player_sleep(i, AWAKE)
			pass
		Global.Role.COUNSELOR:
			for i in role_player_indices:
				set_player_sleep(i, AWAKE)
			pass
		Global.Role.STOWAWAY:
			for i in role_player_indices:
				set_player_sleep(i, AWAKE)
			pass
		Global.Role.SCIENTIST:
			for i in role_player_indices:
				set_player_sleep(i, AWAKE)
			pass
		Global.Role.AGENT:
			for i in role_player_indices:
				set_player_sleep(i, AWAKE)
			pass
		Global.Role.INSOMNIAC:
			for i in role_player_indices:
				set_player_sleep(i, AWAKE)
			pass
	timer_stack.start_next()
		

func get_remote_player_index(index: int) -> int:
	return index if index <= local_player_index else index - 1

func start_sync(action: int):
	sync_collect[action] = []

# Main synchronization
remote func _sync_completed(action: int):
	print("peer sync %s from %s" % [action, get_tree().get_rpc_sender_id()])
	sync_collect[action].append(get_tree().get_rpc_sender_id())
	print("synced %s of %s" % [player_state.size(), sync_collect[action].size()])
	if sync_collect[action].size() == player_state.size():
		sync_all_completed(action)

func sync_all_completed(action: int):
	match action:
		RANDOMIZE:
			messages.broadcast_message("Everyone, look at your role. No-one else can see your role.")
			set_local_reveal(true)
			timer_stack.start_next()

# Call on server after create_game_tree is complete on all clients
func server_start_game():
	print("Starting Game")
	messages.broadcast_message("Starting Game!")
	start_sync(RANDOMIZE)
	server_randomize_roles()

func server_randomize_roles():
	var indices = range(role_state.size())
	indices.shuffle()
	rpc("_set_role_shuffle", indices)

remotesync func _set_role_shuffle(indices):
	print("setting randomized roles")
	for i in range(player_state.size()):
		var role_index = indices.pop_front()
		set_initial_player_role(i, role_index)
	for i in range(town_state.size()):
		set_town_role(i, indices.pop_front())

	messages.send_local_message("You are the %s.\n  %s" % [
		player_role_attr(local_player_index, Global.NAME),
		player_role_attr(local_player_index, Global.DESCRIPTION)
	])
	
	if get_tree().is_network_server():
		_sync_completed(RANDOMIZE)
	else:
		rpc_id(1, "_sync_completed", RANDOMIZE)

func set_initial_player_role(player_index: int, role_index: int):
	print("Setting player %s to role %s" % [player_index, role_index])
	player_state[player_index][Global.ROLE] = role_index
	player_state[player_index][Global.INITIAL_ROLE] = role_index
	if player_index == local_player_index:
		local_player_node.get_player().set_role(role_state[role_index])
	else:
		var player = remote_players_node.get_player(get_remote_player_index(player_index))
		player.set_role(role_state[role_index])

func set_town_role(town_index: int, role_index: int):
	print("Setting town %s to role %s" % [town_index, role_index])
	town_state[town_index][Global.ROLE] = role_index
	town_node.get_player(town_index).set_role(role_state[role_index])

##############################
# REMOTE/SYNC STATE MANAGEMENT
##############################

func set_player_sleep(player_index: int, awake: int):
	rpc("_set_player_sleep", player_index, awake)

remotesync func _set_player_sleep(player_index: int, awake: int):
	if player_index == local_player_index:
		local_player_node.get_player().set_awake(awake)
		match awake:
			AWAKE:
				asleep_overlay.wake()
			ASLEEP:
				asleep_overlay.sleep()
	else:
		remote_players_node.get_player(get_remote_player_index(player_index)).set_awake(awake)

func set_local_reveal(reveal: bool):
	rpc("_set_local_reveal", reveal)

remotesync func _set_local_reveal(reveal: bool):
	local_player_node.get_player().set_reveal(reveal)

func set_player_spotlight(player_index: int, spotlight: bool):
	rpc("_set_player_spotlight", player_index, spotlight)

remotesync func _set_player_spotlight(player_index: int, spotlight: bool):
	if player_index == local_player_index:
		local_player_node.get_player().set_spotlight(spotlight)
	else:
		remote_players_node.get_player(get_remote_player_index(player_index)).set_spotlight(spotlight)
