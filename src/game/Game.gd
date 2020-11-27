extends Node2D

var local_player_id: int = 1
var player_configs: Dictionary = {
	1: {Global.NAME: "test"}, 2: {Global.NAME: "asdf"},
	3: {Global.NAME: "zzzz"}, 4: {Global.NAME: "blep"},
	5: {Global.NAME: "oof"}, 6: {Global.NAME: "foo"},
}
var role_config: Array = [
	Global.Role.ALIEN,
	Global.Role.ALIEN,
	Global.Role.SCIENTIST,
	Global.Role.STOWAWAY,
	Global.Role.CREWMATE,
	Global.Role.CREWMATE,
	Global.Role.CLONE,
	Global.Role.CLONE,
	Global.Role.OFFICER,
]

const town_size = 3

func init(_local_player_id: int, _player_configs: Dictionary, _role_config: Array):
	local_player_id = _local_player_id
	player_configs = _player_configs
	role_config = _role_config
	assert(role_config.size() == player_configs.size() + town_size)

onready var gameboard = $GameBoard
onready var players = $Players
onready var roles = $Roles

onready var timer_stack = $ProgressTimerStack

func _ready():
	# create role cards
	for r in role_config:
		var role_card = Global.RoleCard.instance()
		role_card.init(r)
		roles.add_child(role_card)

	# create players
	for k in player_configs.keys():
		var player = Global.Player.instance()
		player.init(k, player_configs[k][Global.NAME])
		player.set_name(str(k))
		players.add_child(player)

	# place players and assign roles
	var i = 0
	var r = 0
	for k in player_configs.keys():
		var player = players.get_node(str(k))
		if k == local_player_id:
			player.position = gameboard.get_local_player_position()
		else:
			player.position = gameboard.get_remote_player_position(r)
			player.add_to_group("remote")
			r += 1
		
		var role_card = roles.get_child(i)
		player.role = role_card
		player.initial_role = role_card.role
		role_card.position = player.get_role_card_position()
		i += 1
	
	# add remaining roles to town
	for j in town_size:
		var role_card = roles.get_child(player_configs.size() + j)
		role_card.position = gameboard.get_town_card_position(j)
	
	# Set up timer stack
	var progress_node = Global.TextureProgressTimer.instance()
	progress_node.init(0, Color(1, 1, 1), 5)
	timer_stack.add_progress(progress_node)
	for role in Global.night_wake_order:
		if role_config.has(role):
			# connect current role to previous node
			if get_tree().is_network_server():
				progress_node.connect("progress_completed", self, "_end_phase", [role])
			progress_node = Global.TextureProgressTimer.instance()
			progress_node.init(role, Color(1, 1, 1), 5)
			timer_stack.add_progress(progress_node)

func get_players_with_initial_role(role: int):
	var ret = []
	for p in players.get_children():
		if p.initial_role == role:
			ret.append(p)
	return ret
	
############
# SERVER
############

func start_game():
	assert(get_tree().is_network_server())
	for p in players.get_children():
		p.role.set_reveal(true, p.id)
	timer_stack.start_next()

func _end_phase(next_role: int):
	assert(get_tree().is_network_server())
	for p in players.get_children():
		p.set_sleep(true)
	yield(get_tree().create_timer(2), "timeout")
	start_role_action(next_role)

func start_role_action(role: int):
	assert(get_tree().is_network_server())
	print("Starting role action of %s" % [Global.roles[role][Global.NAME]])
	var role_players = get_players_with_initial_role(role)

	match role:
		Global.Role.HOLOGRAM:
			pass
		Global.Role.ALIEN:
			for p in role_players:
				p.set_sleep(false)
		Global.Role.OFFICER:
			for p in role_players:
				p.set_sleep(false)
				for a in get_players_with_initial_role(Global.Role.ALIEN):
					a.set_spotlight(p.id, true)
		Global.Role.CLONE:
			for p in role_players:
				p.set_sleep(false)
		Global.Role.COUNSELOR:
			for p in role_players:
				p.set_sleep(false)
		Global.Role.STOWAWAY:
			for p in role_players:
				p.set_sleep(false)
		Global.Role.SCIENTIST:
			for p in role_players:
				p.set_sleep(false)
		Global.Role.AGENT:
			for p in role_players:
				p.set_sleep(false)
		Global.Role.INSOMNIAC:
			for p in role_players:
				p.set_sleep(false)
	timer_stack.start_next()

#########
# CLIENT
#########
