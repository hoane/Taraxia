extends Node

const Client = preload("res://scenes/Client.tscn")
const Game = preload("res://scenes/Game.tscn")
const GamePlayerCoin = preload("res://scenes/GamePlayerCoin.tscn")
const Lobby = preload("res://scenes/Lobby.tscn")
const LobbyMenu = preload("res://scenes/LobbyMenu.tscn")
const LobbyPlayerLabel = preload("res://scenes/LobbyPlayerLabel.tscn")
const LobbyRoleCoin = preload("res://scenes/LobbyRoleCoin.tscn")
const OptionsMenu = preload("res://scenes/OptionsMenu.tscn")
const RoleCoin = preload("res://scenes/RoleCoin.tscn")
const StartMenu = preload("res://scenes/StartMenu.tscn")
const TextureProgressTimer = preload("res://scenes/TextureProgressTimer.tscn")


const SERVER_PORT = 42069
enum {
	PLAYER,
	ROLE,
	TOWN,
	NAME,
	ATTR,
	COLOR,
	INSTRUCT,
	DESCRIPTION,
	TEAM,
	TEXTURE,
	TEXTURE_MONO,
	ID
}

func init_game_state(players: Dictionary, _roles: Array):
	assert(players.size() <= _roles.size())
	var state = {
		PLAYER: [],
		ROLE: [],
		TOWN: []
	}
	for id in players.keys():
		state[PLAYER].append({
			NAME: players[id]["name"],
			ID: players[id]["peer_id"],
			COLOR: Color(randf(), randf(), randf()),
			ROLE: -1
		})
	for r in _roles:
		state[ROLE].append(r)
	for _i in range(_roles.size() - players.size()):
		state[TOWN].append({
			ROLE: -1
		})

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
		TEXTURE: load("res://assets/icons/crewmate.png"),
		TEXTURE_MONO: load("res://assets/icons/crewmate_mono.png"),
	},
	Role.HOLOGRAM: {
		NAME: "Hologram",
		TEAM: Team.NONE,
		INSTRUCT: "During the night, the Hologram will pick another player and become their role.",
		DESCRIPTION: "A Holodeck accident created a living holographic copy of someone on board.",
		TEXTURE: load("res://assets/icons/crewmate.png"),
		TEXTURE_MONO: load("res://assets/icons/crewmate_mono.png"),
	},
	Role.ALIEN: {
		NAME: "Alien",
		TEAM: Team.ALIEN,
		INSTRUCT: "During the night, the Alien will wake up and see the other Aliens.",
		DESCRIPTION: "Extra-dimensional aliens may have snuck on board during the last light-speed jump.",
		TEXTURE: load("res://assets/icons/alien.png"),
		TEXTURE_MONO: load("res://assets/icons/alien_mono.png"),
	},
	Role.OFFICER: {
		NAME: "1st Officer",
		TEAM: Team.ALIEN,
		INSTRUCT: "During the night, the 1st Officer will wake up and see the Aliens.",
		DESCRIPTION: "The 1st Officer has shown a keen interest in the aliens' unique physiology.",
		TEXTURE: load("res://assets/icons/crewmate.png"),
		TEXTURE_MONO: load("res://assets/icons/crewmate_mono.png"),
	},
	Role.CLONE: {
		NAME: "Clone",
		TEAM: Team.CREW,
		INSTRUCT: "During the night, the Clone will wake up and see the other Clones.",
		DESCRIPTION: "Lesson learned: don't set the transporter to UDP.",
		TEXTURE: load("res://assets/icons/crewmate.png"),
		TEXTURE_MONO: load("res://assets/icons/crewmate_mono.png"),
	},
	Role.COUNSELOR: {
		NAME: "Counselor",
		TEAM: Team.CREW,
		INSTRUCT: "During the night, the Counselor may look at another player's role, or two unused roles.",
		DESCRIPTION: "The ship's Counselor may have some insights into the crew's status.",
		TEXTURE: load("res://assets/icons/crewmate.png"),
		TEXTURE_MONO: load("res://assets/icons/crewmate_mono.png"),
	},
	Role.STOWAWAY: {
		NAME: "Stowaway",
		TEAM: Team.CREW,
		INSTRUCT: "During the night, the Stowaway may swap their role with another player's.",
		DESCRIPTION: "\"Someone grabbed my badge out of my bunk this morning. Can\'t imagine who.\"",
		TEXTURE: load("res://assets/icons/crewmate.png"),
		TEXTURE_MONO: load("res://assets/icons/crewmate_mono.png"),
	},
	Role.SCIENTIST: {
		NAME: "Scientist",
		TEAM: Team.CREW,
		INSTRUCT: "During the night, the Scientist may swap the roles of two other players.",
		DESCRIPTION: "A runaway experiment has caused two crew members to swap bodies.",
		TEXTURE: load("res://assets/icons/crewmate.png"),
		TEXTURE_MONO: load("res://assets/icons/crewmate_mono.png"),
	},
	Role.AGENT: {
		NAME: "Agent",
		TEAM: Team.CREW,
		INSTRUCT: "During the night, the Sleeper Agent will swap their role for an unused one, sight unseen.",
		DESCRIPTION: "Under enough layers of deep cover, it's easy to forget who you really are.",
		TEXTURE: load("res://assets/icons/crewmate.png"),
		TEXTURE_MONO: load("res://assets/icons/crewmate_mono.png"),
	},
	Role.INSOMNIAC: {
		NAME: "Insomniac",
		TEAM: Team.CREW,
		INSTRUCT: "At the end of the night, the Insomniac will wake up and check their own role.",
		DESCRIPTION: "You guys are sleeping?",
		TEXTURE: load("res://assets/icons/crewmate.png"),
		TEXTURE_MONO: load("res://assets/icons/crewmate_mono.png"),
	},
	Role.CREWMATE: {
		NAME: "Crewmate",
		TEAM: Team.CREW,
		INSTRUCT: "The Crewmate does not perform any special action.",
		DESCRIPTION: "Some of the crew aren't holograms, aliens, or robots at all.",
		TEXTURE: load("res://assets/icons/crewmate.png"),
		TEXTURE_MONO: load("res://assets/icons/crewmate_mono.png"),
	},
	Role.ANDROID: {
		NAME: "Android",
		TEAM: Team.ANDROID,
		INSTRUCT: "The Android does not perform any special action. They win if and only if they die at the end of the game.",
		DESCRIPTION: "The Android's developed a bit of a death wish after so many dangerous missions.",
		TEXTURE: load("res://assets/icons/crewmate.png"),
		TEXTURE_MONO: load("res://assets/icons/crewmate_mono.png"),
	},
	Role.SECURITY: {
		NAME: "Security",
		TEAM: Team.CREW,
		INSTRUCT: "The Security Officer does not perform any special action. If they die at the end of the game, their vote dies as well",
		DESCRIPTION: "So anyway, I started blasting...",
		TEXTURE: load("res://assets/icons/crewmate.png"),
		TEXTURE_MONO: load("res://assets/icons/crewmate_mono.png"),
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
