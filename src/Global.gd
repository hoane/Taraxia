extends Node

const Client = preload("res://scenes/Client.tscn")
const Game = preload("res://scenes/Game.tscn")
const GamePlayer = preload("res://scenes/GamePlayer.tscn")
const Lobby = preload("res://scenes/Lobby.tscn")
const LobbyMenu = preload("res://scenes/LobbyMenu.tscn")
const LobbyPlayerLabel = preload("res://scenes/LobbyPlayerLabel.tscn")
const OptionsMenu = preload("res://scenes/OptionsMenu.tscn")
const RoleCoin = preload("res://scenes/RoleCoin.tscn")
const StartMenu = preload("res://scenes/StartMenu.tscn")

const SERVER_PORT = 42069

# Lobby Player:
# "peer_id": local value of get_network_unique_id()
# "player_name": configured player name

const valid_player_colors = [
	Color.red,
	Color.blue,
	Color.green,
	Color.orange,
	Color.purple,
	Color.yellow,
	Color.teal,
	Color.white
]

enum Role {
	NONE,
	VILLAGER,
	WEREWOLF
}

const roles = {
	Role.NONE: {
		"name": "None"
	},
	Role.VILLAGER: {
		"name": "Villager"
	},
	Role.WEREWOLF: {
		"name": "Wereworlf"
	},
}

func _ready():
	randomize()
