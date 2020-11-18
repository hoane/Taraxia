extends Node

var is_server
var player_name
var hostname

func init(_is_server, _player_name, _hostname):
	is_server = _is_server
	player_name = _player_name
	hostname = _hostname

func _ready():
	if is_server:
		start_server()
	else:
		start_client()

	var node = Global.Lobby.instance()
	node.init(is_server, {
		"name": player_name,
		"peer_id": get_tree().get_network_unique_id()
	})
	node.enter_lobby()
	add_child(node)

func start_client():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(hostname, Global.SERVER_PORT)
	get_tree().network_peer = peer

func start_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(Global.SERVER_PORT, 8)
	get_tree().network_peer = peer
