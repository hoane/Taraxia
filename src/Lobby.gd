extends Node

enum State {
	LOBBY,
	GAME
}

var lobby_menu
var lobby_game
var state
var is_server
var local_player
var players: Dictionary = {}
var roles: Array
var preconfigured_ids

func init(_is_server, _local_player):
	local_player = _local_player
	is_server = _is_server
	preconfigured_ids = []

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func enter_lobby():
	state = State.LOBBY
	lobby_menu = Global.LobbyMenu.instance()
	lobby_menu.init(is_server)
	lobby_menu.connect("lobby_start_button", self, "_lobby_start_button")
	add_child(lobby_menu)
	yield(lobby_menu, "ready")
	lobby_menu.add_player(local_player)

func _lobby_start_button(_players, _roles):
	players = _players
	roles = _roles
	var game_state = Global.init_game_state(_players, _roles)
	print("Signalling enter game...")
	rpc("_enter_game", game_state)

remotesync func _enter_game(game_state):
	print("Entering game...")
	state = State.GAME
	lobby_game = Global.Game.instance()
	lobby_game.connect("ready", self, "_on_game_ready")
	lobby_game.init(game_state)
	add_child(lobby_game)
	lobby_menu.queue_free()

func _on_game_ready():
	if get_tree().is_network_server():
		done_game_init()
	else:
		rpc_id(1, "_done_game_init")

remote func _done_game_init():
	done_game_init()

func done_game_init():
	print("Signalling done game init...")
	var id = get_tree().get_rpc_sender_id()

	assert(get_tree().is_network_server())
	assert(id in players) # Exists
	assert(not id in preconfigured_ids) # Was not added yet

	preconfigured_ids.append(id)
	print("Got %s acks of %s" % [preconfigured_ids.size(), players.size()])
	if preconfigured_ids.size() == players.size():
		lobby_game.server_start_game()

func _player_connected(id):
	if state == State.LOBBY:
		rpc_id(id, "add_player", local_player)
		if is_server:
			lobby_menu.set_selected_roles(id)

func _player_disconnected(id):
	if state == State.LOBBY:
		lobby_menu.remove_player(id)

func _connected_ok():
	print("connected")
	
func _connected_fail():
	print("conn_failed")

func _server_disconnected():
	print("server disconnected")

remote func add_player(player):
	assert (player["peer_id"] == get_tree().get_rpc_sender_id())
	lobby_menu.add_player(player)
