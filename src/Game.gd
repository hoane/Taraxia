extends Control

const PLAYER = "player"
const ROLE = "role"
const ATTR = "attributes"
const ID = "peer_id"
const NAME = "name"

# Role state:
# [ roles ]
#
# Player state:
# PLAYER: player value
# ATTR: { Attributes }
#
# Attributes:
# ROLE: player role

var state

var role_state
var player_state
var role_nodes
var player_nodes

func init(_state: Dictionary):
	state = _state

onready var remote_node = $Margin/Areas/Remote
onready var town_node = $Margin/Areas/Town
onready var local_node = $Margin/Areas/Local
onready var self_peer_id = get_tree().get_network_unique_id()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func start_game():
	pass

func create_game_nodes():
	role_nodes = []
	player_nodes = []
	for r in state[ROLE]:
		var role_coin = Global.RoleCoin.instance()
		role_coin.init(r)
		role_nodes.append(role_coin)

	for p in state[PLAYER]:
		var id = p[ID]
		var player = Global.GamePlayer.instance()
		player.set_name(str(id))
		player.init(
			p[NAME],
			Color(randf(), randf(), randf())
		)
		player_nodes.append(player)
		if id == self_peer_id:
			local_node.add_child(player)
		else:
			remote_node.add_child(player)

func assign_roles():
	print("assigning roles...")
	pass

