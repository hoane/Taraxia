extends Node

const AsleepOverlay = preload("res://scenes/AsleepOverlay.tscn")
const Client = preload("res://scenes/Client.tscn")
const Lobby = preload("res://scenes/Lobby.tscn")
const LobbyMenu = preload("res://scenes/LobbyMenu.tscn")
const LobbyPlayerLabel = preload("res://scenes/LobbyPlayerLabel.tscn")
const LobbyRoleCoin = preload("res://scenes/LobbyRoleCoin.tscn")
const OptionsMenu = preload("res://scenes/OptionsMenu.tscn")
const RoleCoin = preload("res://scenes/RoleCoin.tscn")
const StartMenu = preload("res://scenes/StartMenu.tscn")
const TextureProgressTimer = preload("res://scenes/TextureProgressTimer.tscn")

const Game = preload("res://scenes/game/Game.tscn")
const RoleCard = preload("res://scenes/game/RoleCard.tscn")
const Player = preload("res://scenes/game/Player.tscn")

const SERVER_PORT = 42069
enum {
	PLAYER,
	ROLE,
	INITIAL_ROLE
	TOWN,
	NAME,
	ATTR,
	COLOR,
	AWAKE,
	INSTRUCT,
	FLAVOR,
	DESCRIPTION,
	TEAM,
	TEXTURE,
	ID
}

func init_game_state(players: Dictionary, _roles: Array):
	assert(players.size() <= _roles.size())
	var state = {
		PLAYER: {},
		ROLE: [],
	}
	for id in players.keys():
		state[PLAYER][id] = {
			NAME: players[id]["name"],
			ID: players[id]["peer_id"],
			COLOR: Color(randf(), randf(), randf()),
			ROLE: -1,
			INITIAL_ROLE: -1,
			AWAKE: true
		}
	var tmp_roles = _roles.duplicate()
	tmp_roles.shuffle()
	state[ROLE] = tmp_roles

	return state 

# Lobby Player:
# "peer_id": local value of get_network_unique_id()
# "player_name": configured player name

const valid_player_colors = [
	Color.red,
	Color.blue,
	Color.orange,
	Color.purple,
	Color.yellow,
	Color.teal,
	Color.slategray,
	Color.darkgreen,
	Color.lime,
	Color.white
]

enum Role {
	NONE,
	HOLOGRAM,
	ALIEN,
	OFFICER,
	CLONE,
	COUNSELOR,
	STOWAWAY,
	SCIENTIST,
	AGENT,
	INSOMNIAC,
	CREWMATE,
	ANDROID,
	SECURITY
}

enum Team {
	NONE,
	CREW,
	ALIEN,
	ANDROID
}

const teams = {
	Team.NONE: {
		NAME: "None"
	},
	Team.CREW: {
		NAME: "Crew"
	},
	Team.ALIEN: {
		NAME: "Alien"
	},
	Team.ANDROID: {
		NAME: "ANDROID"
	}
}

var roles = {
	Role.NONE: {
		NAME: "",
		TEAM: Team.NONE,
		INSTRUCT: "",
		DESCRIPTION: "",
		FLAVOR: "",
		TEXTURE: load("res://assets/icons/unknown.png"),
	},
	Role.HOLOGRAM: {
		NAME: "Hologram",
		TEAM: Team.NONE,
		INSTRUCT: "",
		DESCRIPTION: "During the night, the Hologram will pick another player and become their role. The Hologram is on the team of the role they copy.",
		FLAVOR: "A Holodeck accident created a living holographic copy of someone on board.",
		TEXTURE: load("res://assets/icons/crewmate.png"),
	},
	Role.ALIEN: {
		NAME: "Alien",
		TEAM: Team.ALIEN,
		INSTRUCT: "Alien, wake up and identify the other Alien. If you are the only Alien, you may view one unused card from the center.",
		DESCRIPTION: "During the night, the Alien will wake up and see the other Aliens. The Alien is on the alien team.",
		FLAVOR: "Extra-dimensional aliens may have snuck on board during the last light-speed jump.",
		TEXTURE: load("res://assets/icons/alien.png"),
	},
	Role.OFFICER: {
		NAME: "1st Officer",
		TEAM: Team.ALIEN,
		INSTRUCT: "1st Officer, wake up and identify the aliens.",
		DESCRIPTION: "During the night, the 1st Officer will wake up and see the Aliens. The 1st Officer is on the alien team.",
		FLAVOR: "The 1st Officer has shown a keen interest in the aliens' unique physiology. ",
		TEXTURE: load("res://assets/icons/crewmate.png"),
	},
	Role.CLONE: {
		NAME: "Clone",
		TEAM: Team.CREW,
		INSTRUCT: "Clone, wake up and identify the other Clone.",
		DESCRIPTION: "During the night, the Clone will wake up and see the other Clones. The Clone is on the crew team.",
		FLAVOR: "Lesson learned: don't set the transporter to UDP.",
		TEXTURE: load("res://assets/icons/crewmate.png"),
	},
	Role.COUNSELOR: {
		NAME: "Counselor",
		TEAM: Team.CREW,
		INSTRUCT: "Counselor, wake up. You may view one other player's card, or two unused cards.",
		DESCRIPTION: "During the night, the Counselor may look at another player's card, or two unused cards. The Counselor is on the crew team.",
		FLAVOR: "The ship's Counselor may have some insights into the crew's status.",
		TEXTURE: load("res://assets/icons/crewmate.png"),
	},
	Role.STOWAWAY: {
		NAME: "Stowaway",
		TEAM: Team.CREW,
		INSTRUCT: "Stowaway, wake up. You may swap your card with another player's.",
		DESCRIPTION: "During the night, the Stowaway may swap their card with another player's. The Stowaway is on the crew team.",
		FLAVOR: "\"Someone grabbed my badge out of my bunk this morning. Can\'t imagine who.\"",
		TEXTURE: load("res://assets/icons/stowaway.png"),
	},
	Role.SCIENTIST: {
		NAME: "Scientist",
		TEAM: Team.CREW,
		INSTRUCT: "Scientist, wake up. You may swap the cards of two other players.",
		DESCRIPTION: "During the night, the Scientist may swap the cards of two other players. The Scientist is on the crew team.",
		FLAVOR: "A runaway experiment has caused two crew members to swap bodies.",
		TEXTURE: load("res://assets/icons/scientist.png"),
	},
	Role.AGENT: {
		NAME: "Agent",
		TEAM: Team.CREW,
		INSTRUCT: "Sleeper Agent, wake up. Swap your card with a card from the center.",
		DESCRIPTION: "During the night, the Sleeper Agent will swap their card for an unused one. The Sleeper Agent is on the crew team.",
		FLAVOR: "Under enough layers of deep cover, it's easy to forget who you really are.",
		TEXTURE: load("res://assets/icons/crewmate.png"),
	},
	Role.INSOMNIAC: {
		NAME: "Insomniac",
		TEAM: Team.CREW,
		INSTRUCT: "Insomniac, wake up and look at your own card.",
		DESCRIPTION: "At the end of the night, the Insomniac will wake up and check their own card. The Insomniac is on the crew team.",
		FLAVOR: "You guys are sleeping?",
		TEXTURE: load("res://assets/icons/crewmate.png"),
	},
	Role.CREWMATE: {
		NAME: "Crewmate",
		TEAM: Team.CREW,
		INSTRUCT: "",
		DESCRIPTION: "The Crewmate does not perform any special action. The Crewmate is on the crew team.",
		FLAVOR: "Some of the crew aren't holograms, aliens, or robots at all.",
		TEXTURE: load("res://assets/icons/crewmate.png"),
	},
	Role.ANDROID: {
		NAME: "Android",
		TEAM: Team.ANDROID,
		INSTRUCT: "",
		DESCRIPTION: "The Android does not perform any special action. They win if and only if they die at the end of the game.",
		FLAVOR: "The Android's developed a bit of a death wish after so many dangerous missions.",
		TEXTURE: load("res://assets/icons/crewmate.png"),
	},
	Role.SECURITY: {
		NAME: "Security",
		TEAM: Team.CREW,
		INSTRUCT: "",
		DESCRIPTION: "The Security Officer does not perform any special action. If they die at the end of the game, their vote dies as well. The Security Officer is on the crew team.",
		FLAVOR: "So anyway, I started blasting...",
		TEXTURE: load("res://assets/icons/crewmate.png"),
	},
}

const night_wake_order = [
	Role.HOLOGRAM,
	Role.ALIEN,
	Role.OFFICER,
	Role.CLONE,
	Role.COUNSELOR,
	Role.STOWAWAY,
	Role.SCIENTIST,
	Role.AGENT,
	Role.INSOMNIAC,
	# Role.CREWMATE,
	# Role.ANDROID,
	# Role.SECURITY,
]

const available_roles = [
	Role.CREWMATE,
	Role.CREWMATE,
	Role.CREWMATE,
	Role.ALIEN,
	Role.ALIEN,
	Role.COUNSELOR,
	Role.STOWAWAY,
	Role.SCIENTIST,
	Role.ANDROID,
	Role.AGENT,
	Role.SECURITY,
	Role.CLONE,
	Role.CLONE,
	Role.INSOMNIAC,
	Role.OFFICER,
	Role.HOLOGRAM,
]

func _ready():
	OS.min_window_size = Vector2(400, 225)
	randomize()
